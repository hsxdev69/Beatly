import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/constants/api_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiUrlController = TextEditingController();
  bool _pureBlack = false;
  String _audioQuality = 'high';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _apiUrlController.text = prefs.getString('custom_api_url') ?? ApiConstants.apiBaseUrl;
        _pureBlack = prefs.getBool('pure_black') ?? false;
        _audioQuality = prefs.getString('audio_quality') ?? 'high';
      });
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  void _showApiUrlDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: const Text('Development API Base URL', style: AppTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supports Android Emulator (http://10.0.2.2:8080) or Localhost (http://localhost:8080).',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. http://localhost:8080',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final url = _apiUrlController.text.trim();
              await _saveSetting('custom_api_url', url);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // APPEARANCE
          _buildSectionHeader('APPEARANCE'),
          SwitchListTile(
            activeThumbColor: AppColors.primary,
            title: const Text('Pure Black (OLED Mode)', style: AppTypography.bodyLarge),
            subtitle: const Text('Completely pitch black background for OLED screens', style: AppTypography.bodySmall),
            value: _pureBlack,
            onChanged: (val) {
              setState(() => _pureBlack = val);
              _saveSetting('pure_black', val);
            },
          ),
          const Divider(color: AppColors.darkGlassBorder),

          // AUDIO PLAYBACK
          _buildSectionHeader('AUDIO PLAYBACK'),
          ListTile(
            title: const Text('Audio Quality', style: AppTypography.bodyLarge),
            subtitle: Text(_audioQuality == 'high' ? 'High (256 kbps AAC)' : 'Normal (128 kbps)', style: AppTypography.bodySmall),
            trailing: DropdownButton<String>(
              value: _audioQuality,
              dropdownColor: AppColors.darkSurfaceVariant,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('Normal (128 kbps)')),
                DropdownMenuItem(value: 'high', child: Text('High (256 kbps)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _audioQuality = val);
                  _saveSetting('audio_quality', val);
                }
              },
            ),
          ),
          const Divider(color: AppColors.darkGlassBorder),

          // NETWORK & SERVERS
          _buildSectionHeader('NETWORK & BACKEND'),
          ListTile(
            title: const Text('Stream Server / API URL', style: AppTypography.bodyLarge),
            subtitle: Text(
              _apiUrlController.text.isNotEmpty ? _apiUrlController.text : ApiConstants.apiBaseUrl,
              style: AppTypography.bodySmall,
            ),
            trailing: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
            onTap: _showApiUrlDialog,
          ),
          const Divider(color: AppColors.darkGlassBorder),

          // ABOUT
          _buildSectionHeader('ABOUT'),
          const ListTile(
            title: Text('Echo Music', style: AppTypography.bodyLarge),
            subtitle: Text('Version 1.0.0 (Flutter Clone) • InnerTube Playback', style: AppTypography.bodySmall),
            leading: Icon(Icons.info_outline_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 1.2),
      ),
    );
  }
}
