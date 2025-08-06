import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/network/local/cache_helper.dart';
import 'package:newsly/core/network/remote/api_endpoints.dart';
import 'package:newsly/core/network/remote/dio_helper.dart';
import 'package:newsly/features/home/data/models/everything_model.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';
import 'package:newsly/features/home/presentation/widgets/categories_list.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  bool isDark = false;

  void changeThemeMode({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
      emit(HomeChangeThemeAppState());
    } else {
      isDark = !isDark;
      CacheHelper.saveData(key: 'isDark', value: isDark);
      emit(HomeChangeThemeAppState());
    }
  }

  TextEditingController searchController = TextEditingController();

  EverythingModel? searchModel;

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
            l,
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
            l,
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
}
