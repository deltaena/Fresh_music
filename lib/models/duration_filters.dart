enum DurationFilter { ofMonth1, ofMonth2, ofMonth3 }

extension DurationFiltersExtension on DurationFilter{
  int get value {
    switch(this){
      case DurationFilter.ofMonth1: return 30;
      case DurationFilter.ofMonth2: return 60;
      case DurationFilter.ofMonth3: return 90;
    }
  }

  Duration get duration => Duration(days: value);

  String get name => value.toString();
}