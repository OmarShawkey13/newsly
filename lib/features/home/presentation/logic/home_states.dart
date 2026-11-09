abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class HomeLoadingState extends HomeStates {}

class HomeErrorState extends HomeStates {
  final String error;

  HomeErrorState(this.error);
}

class HomeSuccessState extends HomeStates {}

class HomeSearchInputChangedState extends HomeStates {}

class HomeSearchClearedState extends HomeStates {}

class ChangeSelectedIndexState extends HomeStates {}
