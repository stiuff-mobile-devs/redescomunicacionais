import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

class PublicationTermsDialog extends StatefulWidget {
  const PublicationTermsDialog({super.key});

  @override
  State<PublicationTermsDialog> createState() =>
      _PublicationTermsDialogState();
}

class _PublicationTermsDialogState extends State<PublicationTermsDialog> {
  final Map<String, bool> checklist = {
    "titulo_curto_direto": false,
    "texto_simples": false,
    "estrutura_texto": false,

    "fatos_conferidos": false,
    "origem_informacoes_imagens": false,
    "sem_boatos_redes_sociais": false,

    "sem_preconceito_violencia_ofensa": false,
    "privacidade_criancas_vitimas": false,
    "midias_nao_manipuladas": false,
    "sem_ia": false,
    "sem_copia": false,

    "direito_uso_fotos_videos": false,
    "imagem_nao_sensacionalista": false,
    "local_data_fonte_imagens": false,

    "materia_assinada": false,
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
                LocaleKeys.termsNewsClarity.tr,
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
                LocaleKeys.termNewsStructure,
              ),

              const Divider(),

              Text(
                LocaleKeys.termsInfoQuality.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              buildCheckItem(
                "fatos_conferidos",
                LocaleKeys.termFactsChecked,
              ),

              buildCheckItem(
                "origem_informacoes_imagens",
                LocaleKeys.termSourcesIndicated,
              ),

              buildCheckItem(
                "sem_boatos_redes_sociais",
                LocaleKeys.termNoRumors,
              ),

              const Divider(),

              Text(
                LocaleKeys.termsEthics.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              buildCheckItem(
                "sem_preconceito_violencia_ofensa",
                LocaleKeys.termNoPrejudice,
              ),

              buildCheckItem(
                "privacidade_criancas_vitimas",
                LocaleKeys.termPrivacy,
              ),

              buildCheckItem(
                "midias_nao_manipuladas",
                LocaleKeys.termNoManipulation,
              ),

              buildCheckItem(
                "sem_ia",
                LocaleKeys.termNoAi,
              ),

              buildCheckItem(
                "sem_copia",
                LocaleKeys.termNoCopy,
              ),

              const Divider(),

              Text(
                LocaleKeys.termsImages.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              buildCheckItem(
                "direito_uso_fotos_videos",
                LocaleKeys.termMediaRights,
              ),

              buildCheckItem(
                "imagem_nao_sensacionalista",
                LocaleKeys.termNoSensationalism,
              ),

              buildCheckItem(
                "local_data_fonte_imagens",
                LocaleKeys.termImageCredits,
              ),

              const Divider(),

              Text(
                LocaleKeys.termsTransparency.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              buildCheckItem(
                "materia_assinada",
                LocaleKeys.termSigned,
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