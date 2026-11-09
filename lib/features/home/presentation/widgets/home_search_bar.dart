import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = HomeCubit.get(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (_, current) =>
        current is ThemeChangeThemeState ||
            current is ThemeLanguageUpdatedState,
        builder: (context, _) {
          final translation = appTranslation();

          return BlocBuilder<HomeCubit, HomeStates>(
            buildWhen: (_, current) =>
            current is HomeSearchInputChangedState ||
                current is HomeSearchClearedState,
            builder: (context, _) {
              final hasText = cubit.searchController.text.isNotEmpty;

              return SearchBar(
                controller: cubit.searchController,
                onChanged: cubit.searchNewsDebounced,
                onSubmitted: (value) {
                  final query = value.trim();
                  if (query.isNotEmpty) {
                    cubit.searchNews(text: query);
                  }
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                hintText: translation.get('search_articles'),
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (hasText)
                    IconButton(
                      tooltip: translation.get('clear_search'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: cubit.clearSearch,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}