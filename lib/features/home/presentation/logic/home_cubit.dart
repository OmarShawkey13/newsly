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

  static const Duration _debounceDuration = Duration(seconds: 2);
  static const int _minSearchLength = 3;
  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
  );

  final TextEditingController searchController = .new();
  Timer? _searchDebounce;
  bool _hasSearchText = false;
  int _selectedIndex = 0;
  int _requestGeneration = 0;

  EverythingModel? searchModel;

  int get selectedIndex => _selectedIndex;
  bool get hasSearchText => _hasSearchText;

  set selectedIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    emit(ChangeSelectedIndexState());
    getTopHeadlines();
  }

  void searchNewsDebounced(String text) {
    _searchDebounce?.cancel();

    final hasSearchText = text.isNotEmpty;
    final wasSearchText = _hasSearchText;
    if (_hasSearchText != hasSearchText) {
      _hasSearchText = hasSearchText;
      emit(HomeSearchInputChangedState());
    }

    if (wasSearchText && !hasSearchText) {
      unawaited(getTopHeadlines());
      return;
    }

    final query = text.trim();
    if (query.characters.length <= _minSearchLength) return;

    _searchDebounce = Timer(
      _debounceDuration,
      () => searchNews(text: query),
    );
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    _requestGeneration++;
    searchController.clear();
    _hasSearchText = false;
    emit(HomeSearchClearedState());
    unawaited(getTopHeadlines());
  }

  Future<void> searchNews({required String text}) async {
    await _fetchNews(
      url: everythingEndpoint,
      search: text,
      lang: _arabicRegex.hasMatch(text) ? 'ar' : 'en',
      query: {'searchIn': 'title,content'},
    );
  }

  Future<void> getTopHeadlines() async {
    await _fetchNews(
      url: topHeadlinesEndpoint,
      query: {
        'country': 'us',
        'category': categories[_selectedIndex].toLowerCase(),
      },
    );
  }

  Future<void> _fetchNews({
    required String url,
    String? search,
    String? lang,
    Map<String, dynamic>? query,
  }) async {
    final requestGeneration = ++_requestGeneration;
    searchModel = null;
    emit(HomeLoadingState());

    final result = await DioHelper.getData(
      url: url,
      search: search,
      lang: lang,
      query: query,
    );

    if (isClosed || requestGeneration != _requestGeneration) return;

    result.fold(
      (failure) => emit(HomeErrorState(failure.message)),
      (response) {
        searchModel = EverythingModel.fromMap(response.data);
        emit(HomeSuccessState());
      },
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
