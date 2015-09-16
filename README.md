# iOSCityGuide
A template app that allows easy creation of a City Guide, which shows points-of-interest on a map and gives additional information. This app can easily be adapted to support any city/sights on earth

# How it works
The app loads sights information from a JSON file. It then parses this information into Categories and Sight objects, which it displays in a UITableView and MapView. Users can select sights and navigate there via Apple Maps. The app also employs a webview, which loads general information on the web about the given City. UI is handled completely by code, without the use of Storyboards. The UI renders differently on iPhone and iPad, but uses the same classes.

# Screenshots

![alt tag](https://raw.githubusercontent.com/rogerdcarvalho/iOSCityGuide/master/Screenshot1.png)
![alt tag](https://raw.githubusercontent.com/rogerdcarvalho/iOSCityGuide/master/Screenshot2.png)
