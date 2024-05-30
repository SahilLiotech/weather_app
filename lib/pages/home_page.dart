import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/const.dart';
import 'package:weather/weather.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/helpers/db_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWHEATHER_API_KEY);

  final List<String> cityList = [
    "Dhoraji",
    "Ahmedabad",
    "Surat",
    "Vadodara",
    "Rajkot",
    "Bhavnagar",
    "Junagadh",
    "Hyderabad",
    "Bengaluru",
    "Pune",
    "Mumbai",
    "Chennai",
    "Kolkata",
    "Delhi",
    "Lucknow",
    "Kanpur",
    "Nagpur",
    "Patna",
    "Indore",
    "Jodhpur",
    "Thane",
    "Nashik",
    "Ludhiana",
    "Agra",
    "Allahabad",
    "Coimbatore",
    "Chandigarh",
    "Varanasi",
    "Jaipur",
    "Kota",
    "Noida",
    "Ghaziabad",
    "Firozabad",
    "Meerut",
    "Moradabad",
    "Vijayawada",
    "Visakhapatnam",
    "Faridabad",
    "Gwalior",
    "Vizianagaram",
    "Guntur",
    "Madurai",
    "Karnal",
  ];

  final TextEditingController _searchController = TextEditingController();
  Weather? _currentWeather;
  List<Weather>? _forecast;
  String? _selectedCity;
  List<String> _filteredCities = [];
  final dbHelper = WeatherDataBaseHelper();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  Future<void> _loadSelectedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? city = prefs.getString('selectedCity') ?? "Dhoraji";
    _fetchWeatherModel(city);
  }

  Future<void> _fetchWeatherModel(String city) async {
    setState(() {
      _isLoading = true;
    });

    Weather currentWeather = await _wf.currentWeatherByCityName(city);
    List<Weather> forecast = await _wf.fiveDayForecastByCityName(city);

    setState(() {
      _currentWeather = currentWeather;
      _forecast = forecast;
      _selectedCity = city;
      _isLoading = false;
    });
  }

  Future<void> _saveSelectedCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  void _filterCityList(String query) {
    setState(() {
      _filteredCities = cityList
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent.shade100,
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
        elevation: 5.0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_currentWeather == null || _forecast == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterCityList(value);
                if (value.isEmpty) {
                  setState(() {
                    _filteredCities = [];
                  });
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                hintText: 'Search City',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _filteredCities = [];
                          });
                        },
                      )
                    : const Icon(Icons.search),
              ),
            ),
          ),
          _filteredCities.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredCities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredCities[index]),
                      onTap: () {
                        _searchController.text = _filteredCities[index];
                        _fetchWeatherModel(_filteredCities[index]);
                        _saveSelectedCity(_filteredCities[index]);
                        setState(() {
                          _filteredCities = [];
                        });
                      },
                    );
                  },
                )
              : Container(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _currentWeatherUI(),
          _forecastUI(),
        ],
      ),
    );
  }

  Widget _currentWeatherUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _dateTimeInfo(),
          _weatherIcon(),
          _currentTemp(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo()
        ],
      ),
    );
  }

  Widget _forecastUI() {
    final forecastByDay = groupBy(_forecast!,
        (Weather weather) => DateFormat('yyyy-MM-dd').format(weather.date!));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: forecastByDay.length,
      itemBuilder: (context, index) {
        final dayForecast = forecastByDay.entries.toList()[index].value;
        final weather = dayForecast.first;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.grey.shade400,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Image.network(
                    "http://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png"),
                title: Text(DateFormat("EEEE, d MMM").format(weather.date!)),
                subtitle: Text(weather.weatherDescription ?? ""),
                trailing: Text(
                  "${weather.temperature!.celsius!.toStringAsFixed(0)}\u00b0C",
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _locationHeader() {
    return Text(
      _currentWeather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _currentWeather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("HH:MM a").format(now),
          style: const TextStyle(
            fontSize: 35,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 5),
            Text(
              DateFormat("d-MM-yyyy").format(now),
              style: const TextStyle(fontWeight: FontWeight.w400),
            )
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_currentWeather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _currentWeather?.weatherDescription ?? "",
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_currentWeather?.temperature!.celsius!.toStringAsFixed(0)}\u00b0C",
      style: const TextStyle(
        fontSize: 36.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "${_forecast?.firstWhereOrNull((weather) => DateFormat('yyyy-MM-dd').format(weather.date!) == DateFormat('yyyy-MM-dd').format(_currentWeather!.date!))?.tempMin?.celsius?.toStringAsFixed(0)}\u00b0C",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Min Temp"),
            ],
          ),
          Column(
            children: [
              Text(
                "${_forecast?.firstWhereOrNull((weather) => DateFormat('yyyy-MM-dd').format(weather.date!) == DateFormat('yyyy-MM-dd').format(_currentWeather!.date!))?.tempMax?.celsius?.toStringAsFixed(0)}\u00b0C",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Max Temp"),
            ],
          ),
        ],
      ),
    );
  }
}
