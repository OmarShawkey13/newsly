import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              appTranslation().get('top_stories'),
              style: TextStylesManager.semiBold18.copyWith(
                color: ColorsManager.currentTextColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
