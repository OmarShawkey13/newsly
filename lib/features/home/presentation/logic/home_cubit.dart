import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/models/everything_model.dart';
import 'package:newsly/core/network/remote/api_endpoints.dart';
import 'package:newsly/core/network/remote/dio_helper.dart';
import 'package:newsly/features/home/logic/home_categories.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  EverythingModel? searchModel;

  void searchNewsDebounced(String text) {
    _searchDebounce?.cancel();
    emit(HomeSearchInputChangedState());
    if (text.characters.length <= 3) return;

    _searchDebounce = Timer(
      const Duration(seconds: 2),
      () => searchNews(text: text),
    );
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    emit(HomeSearchClearedState());
  }

  void searchNews({
    required String text,
  }) async {
    searchModel = null;
    emit(HomeLoadingState());
    final result = await DioHelper.getData(
      url: everythingEndpoint,
      search: text.toLowerCase(),
      query: {
        'searchIn': 'title,content',
      },
    );
    result.fold(
      (l) {
        emit(
          HomeErrorState(
            l.message,
          ),
        );
      },
      (r) {
        searchModel = EverythingModel.fromMap(r.data);
        emit(
          HomeSuccessState(),
        );
      },
    );
  }

  void getTopHeadlines() async {
    searchModel = null;

    emit(HomeLoadingState());

    final result = await DioHelper.getData(
      url: topHeadlinesEndpoint,
      query: {
        'country': 'us',
        'category': categories[selectedIndex].toLowerCase(),
      },
    );

    result.fold(
      (l) {
        emit(
          HomeErrorState(
            l.message,
          ),
        );
      },
      (r) {
        searchModel = EverythingModel.fromMap(r.data);
        emit(
          HomeSuccessState(),
        );
      },
    );
  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    getTopHeadlines();
    emit(ChangeSelectedIndexState());
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
