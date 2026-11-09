import 'package:newsly/core/models/translations.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';

TranslationModel appTranslation() =>
    ThemeCubit.currentTranslation ?? TranslationModel.fromJson({});
