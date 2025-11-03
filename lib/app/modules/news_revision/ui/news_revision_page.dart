import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news_revision/controller/news_revision_controller.dart';

class NewsRevisionPage extends GetView<NewsRevisionController> {
  const NewsRevisionPage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(title: Text('NewsRevisionPage')),

    body: SafeArea(
      child: Text('NewsRevisionPageController'))
    );
  }
}