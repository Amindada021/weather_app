class SixDaysWeather {
  SixDaysWeather(this._dataTime, this._temp, this._icon);

  var _dataTime;

  get dataTime => _dataTime;
  var _temp;
  String _icon;

  get temp => _temp;



  String get icon => _icon;
}
