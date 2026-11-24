import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/utils/app_snackbar.dart';
import '../../data/repositories/baby_generator_repository.dart';
import '../../data/models/baby_config_model.dart';
import '../../../../../core/theme/app_theme.dart';

class BabyGeneratorPage extends StatefulWidget {
  const BabyGeneratorPage({Key? key}) : super(key: key);

  @override
  State<BabyGeneratorPage> createState() => _BabyGeneratorPageState();
}

class _BabyGeneratorPageState extends State<BabyGeneratorPage> {
  final BabyGeneratorRepository _repository = BabyGeneratorRepository();
  final ImagePicker _picker = ImagePicker();
  
  File? _image1;
  File? _image2;
  
  bool _isLoadingConfig = true;
  bool _isGenerating = false;

  List<ConfigOption> _genders = [];
  List<ConfigOption> _skins = [];
  
  String? _selectedGender;
  String? _selectedSkin;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    final result = await _repository.fetchBabyConfig();
    if (!mounted) return;

    setState(() {
      _isLoadingConfig = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (config) {
        setState(() {
          _genders = config.genders;
          _skins = config.skins;
          if (_genders.isNotEmpty) _selectedGender = _genders.first.id;
          if (_skins.isNotEmpty) _selectedSkin = _skins.first.id;
        });
      },
    );
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (index == 1) {
          _image1 = File(image.path);
        } else {
          _image2 = File(image.path);
        }
      });
    }
  }

  void _generateBaby() async {
    if (_image1 == null || _image2 == null) {
      AppSnackbar.info(context, 'Please select both images first.');
      return;
    }

    if (_selectedGender == null || _selectedSkin == null) {
      AppSnackbar.info(context, 'Configuration not loaded yet. Please wait.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final result = await _repository.generateBaby(
      image1: _image1!,
      image2: _image2!,
      gender: _selectedGender!,
      skin: _selectedSkin!,
    );

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (imageUrl) {
        context.push('/result', extra: {
          'originalPath': _image1!.path, // Displaying mother's image as original for comparison
          'resultUrl': imageUrl,
          'feature': 'AI Baby Generator',
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textMain),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "AI Baby Generator",
          style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingConfig
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGES PICKER ROW
                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePicker(
                            image: _image1,
                            label: "Mother's Photo",
                            onTap: () => _pickImage(1),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildImagePicker(
                            image: _image2,
                            label: "Father's Photo",
                            onTap: () => _pickImage(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // GENDER DROPDOWN
                    const Text(
                      "Gender",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedGender != null)
                      _buildDropdown(
                        value: _selectedGender!,
                        items: _genders,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedGender = val);
                        },
                      ),
                    const SizedBox(height: 24),
                    
                    // SKIN DROPDOWN
                    const Text(
                      "Skin Tone",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedSkin != null)
                      _buildDropdown(
                        value: _selectedSkin!,
                        items: _skins,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSkin = val);
                        },
                      ),
                    const SizedBox(height: 40),
                    
                    // GENERATE BUTTON
                    _isGenerating
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
                            ),
                          )
                        : PrimaryButton(
                            text: "Generate Baby ✨",
                            onTap: _generateBaby,
                          ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImagePicker({
    required File? image,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfacePrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPurple.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: image != null
              ? DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<ConfigOption> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
          dropdownColor: AppTheme.surfacePrimary,
          items: items.map((ConfigOption item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
