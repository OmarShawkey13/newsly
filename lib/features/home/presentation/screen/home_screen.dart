import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';
import 'package:newsly/features/home/presentation/widgets/categories_list.dart';
import 'package:newsly/features/home/presentation/widgets/search_list_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  Timer? debounce;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final cubit = HomeCubit.get(context);
        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: cubit.isDark
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          'Search Your Daily News',
                          style: TextStylesManager.bold20(context).copyWith(
                            color: cubit.isDark
                                ? ColorsManager.textColorDark
                                : ColorsManager.textColor,
                          ),
                        ),
                        const Spacer(),
                        const CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(
                            'https://avatars.githubusercontent.com/u/81522507?v=4',
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace16,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SearchBar(
                      controller: cubit.searchController,
                      textStyle: WidgetStatePropertyAll(
                        TextStylesManager.regular18(context).copyWith(
                          color: cubit.isDark
                              ? ColorsManager.textColorDark
                              : ColorsManager.textColor,
                        ),
                      ),
                      onChanged: (String text) {
                        if (text.characters.length > 3) {
                          if (debounce?.isActive ?? false) debounce!.cancel();

                          debounce = Timer(const Duration(seconds: 2), () {
                            // Call your API or search logic here
                            cubit.searchNews(
                              text: text,
                            );
                            // Example: fetchResults(query);
                          });
                        }
                      },
                      overlayColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      backgroundColor: WidgetStatePropertyAll(
                        cubit.isDark
                            ? ColorsManager.searchBackgroundDark
                            : ColorsManager.searchBackground,
                      ),
                      elevation: const WidgetStatePropertyAll(0.0),
                      hintStyle: WidgetStatePropertyAll(
                        TextStylesManager.regular18(context).copyWith(
                          color: cubit.isDark
                              ? ColorsManager.searchHintTextDark
                              : ColorsManager.searchHintText,
                        ),
                      ),
                      hintText: 'Search articles...',
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                          side: BorderSide(
                            color: cubit.isDark
                                ? ColorsManager.searchBorderDark
                                : ColorsManager.searchBorder,
                          ),
                        ),
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      leading: Icon(
                        Icons.search,
                        color: cubit.isDark
                            ? ColorsManager.searchIconColorDark
                            : ColorsManager.searchIconColor,
                      ),
                      trailing: cubit.searchController.text.isNotEmpty
                          ? [
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: cubit.isDark
                                      ? ColorsManager.searchIconColorDark
                                      : ColorsManager.searchIconColor,
                                ),
                                onPressed: () {
                                  cubit.searchController.clear();
                                  cubit.selectedIndex = cubit.selectedIndex;
                                },
                              ),
                            ]
                          : null,
                    ),
                  ),
                  verticalSpace24,
                  const CategoriesList(),
                  verticalSpace24,
                  const Expanded(
                    child: SearchListWidget(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
