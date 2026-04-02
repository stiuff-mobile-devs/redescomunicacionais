import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:redescomunicacionais/app/modules/news/controller/create_news_form_controller.dart';
import 'package:redescomunicacionais/app/utils/components/markdown_editor.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';

class CreateNewsPage extends GetView<CreateNewsFormController> {
  const CreateNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_news'.tr),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(controller),
                      const SizedBox(height: 16),
                      _buildSubtitleField(controller),
                      const SizedBox(height: 16),
                      _buildCategorySelection(controller),
                      const SizedBox(height: 16),
                      _buildCitySelection(controller),
                      const SizedBox(height: 16),
                      _buildTypeSelection(controller),
                      const SizedBox(height: 16),
                      _buildYouTubeUrlField(controller),
                      const SizedBox(height: 16),
                      _buildMarkdownEditor(controller),
                      const SizedBox(height: 16),
                      _buildImagePicker(controller),
                      const SizedBox(height: 16),
                      _buildImageInfo(),
                      _buildImagePreview(controller),
                      const SizedBox(height: 16),
                      _buildImageMessage(controller),
                      const SizedBox(height: 16),
                      _buildPublishButton(controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(CreateNewsFormController controller) {
    return TextFormField(
      controller: controller.titleController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'title'.tr,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'title_required'.tr;
        }
        return null;
      },
    );
  }

  Widget _buildSubtitleField(CreateNewsFormController controller) {
    return TextFormField(
      controller: controller.subtitleController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'subtitle_optional'.tr,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCategorySelection(CreateNewsFormController controller) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Text(
                  'select_categories'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Column(
                    children: controller.categories.map((category) {
                      return CheckboxListTile(
                        title: Text(
                          category,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: controller.selectedCategories.contains(category),
                        onChanged: (bool? isChecked) {
                          controller.toggleCategory(category);
                        },
                        activeColor: Colors.blue,
                        side: const BorderSide(color: Colors.white, width: 2),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (controller.showCategoryError)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'select_at_least_one_category'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ));
  }

  Widget _buildCitySelection(CreateNewsFormController controller) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Text(
                  'select_city'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Column(
                    children: controller.cities.map((city) {
                      return CheckboxListTile(
                        title: Text(
                          city,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: controller.selectedCities.contains(city),
                        onChanged: (bool? isChecked) {
                          controller.toggleCity(city);
                        },
                        activeColor: Colors.blue,
                        side: const BorderSide(color: Colors.white, width: 2),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (controller.showCityError)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'select_at_least_one_city'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ));
  }

  Widget _buildTypeSelection(CreateNewsFormController controller) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Text(
                  'select_type'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Column(
                    children: controller.types.map((selectedType) {
                      return CheckboxListTile(
                        title: Text(
                          selectedType,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: controller.type == selectedType,
                        onChanged: (bool? isChecked) {
                          controller.toggleType(selectedType);
                        },
                        activeColor: Colors.blue,
                        side: const BorderSide(color: Colors.white, width: 2),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (controller.showTypeError)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'select_at_least_one_type'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ));
  }

  Widget _buildYouTubeUrlField(CreateNewsFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.videoUrlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'youtube_url_optional'.tr,
            labelStyle: const TextStyle(color: Colors.white),
            hintText: "https://www.youtube.com/watch?v=...",
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.video_library, color: Colors.white),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'paste_youtube_link_here'.tr,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownEditor(CreateNewsFormController controller) {
    return Expanded(
      child: MarkdownEditor(controller: controller.bodyController),
    );
  }

  Widget _buildImagePicker(CreateNewsFormController controller) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => controller.imageController.pickImage(),
        icon: const Icon(Icons.image),
        label: Text(
          'add_image'.tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildImageInfo() {
    return Text(
      'image_requirements'.tr,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildImagePreview(CreateNewsFormController controller) {
    return Center(
      child: Obx(() {
        if (controller.imageController.base64String != null) {
          return Column(
            children: [
              Image.memory(
                base64Decode(controller.imageController.base64String!),
                height: 150,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildImageMessage(CreateNewsFormController controller) {
    return Obx(() => Text(
          controller.imageController.message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ));
  }

  Widget _buildPublishButton(CreateNewsFormController controller) {
    return ElevatedButton(
      onPressed: controller.validateAndPublish,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.blue,
      ),
      child: Text(
        'publish_news'.tr,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
