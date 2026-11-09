import 'package:flutter/material.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/features/home/presentation/widgets/categories_list.dart';
import 'package:newsly/features/home/presentation/widgets/home_header.dart';
import 'package:newsly/features/home/presentation/widgets/home_search_bar.dart';
import 'package:newsly/features/home/presentation/widgets/search_list_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeHeader(),
      body: SafeArea(
        child: Column(
          children: [
            const HomeSearchBar(),
            verticalSpace24,
            const CategoriesList(),
            verticalSpace24,
            const Expanded(child: SearchListWidget()),
          ],
        ),
      ),
    );
  }
}
