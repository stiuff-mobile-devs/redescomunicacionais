import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

class PublicationOpinionTermsDialog extends StatefulWidget {
  const PublicationOpinionTermsDialog({super.key});

  @override
  State<PublicationOpinionTermsDialog> createState() =>
      _PublicationOpinionTermsDialogState();
}

class _PublicationOpinionTermsDialogState
    extends State<PublicationOpinionTermsDialog> {
  final Map<String, bool> checklist = {
    "titulo_curto_direto": false,
    "texto_simples": false,
    "estrutura_texto": false,
    "pessoas_respeitosamente": false,
    "fatos_dados_conferidos": false,
    "opiniao_com_fundamento": false,
    "assumo_opiniao_posicionamento": false,
    "revisao_gramatical": false,
  };

  bool get allAccepted =>
      checklist.values.every((item) => item == true);

  // `textKey` é uma chave de LocaleKeys
  Widget buildCheckItem(
      String key,
      String textKey,
      ) {
    return CheckboxListTile(
      value: checklist[key],
      onChanged: (value) {
        setState(() {
          checklist[key] = value ?? false;
        });
      },
      title: Text(
        textKey.tr,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        LocaleKeys.publicationGuideTitle.tr,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.termsArticleClarity.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              buildCheckItem(
                "titulo_curto_direto",
                LocaleKeys.termShortTitle,
              ),

              buildCheckItem(
                "texto_simples",
                LocaleKeys.termSimpleText,
              ),

              buildCheckItem(
                "estrutura_texto",
                LocaleKeys.termOpinionStructure,
              ),

              buildCheckItem(
                "pessoas_respeitosamente",
                LocaleKeys.termRespectPeople,
              ),

              buildCheckItem(
                "fatos_dados_conferidos",
                LocaleKeys.termOpinionFactsChecked,
              ),

              buildCheckItem(
                "opiniao_com_fundamento",
                LocaleKeys.termOpinionGrounded,
              ),

              buildCheckItem(
                "assumo_opiniao_posicionamento",
                LocaleKeys.termOwnOpinion,
              ),

              buildCheckItem(
                "revisao_gramatical",
                LocaleKeys.termGrammarReview,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            LocaleKeys.cancel.tr,
          ),
        ),
        ElevatedButton(
          onPressed: allAccepted
              ? () {
            Get.back(
              result: {
                "acceptedAll": true,
                "checklist": checklist,
              },
            );
          }
              : null,
          child: Text(
            LocaleKeys.confirmPublication.tr,
          ),
        ),
      ],
    );
  }
}