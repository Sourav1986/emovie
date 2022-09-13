# E movie
Shows latest and greatest collection of movies.

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#getting-started">Getting Started</a>
    </li>
    <li><a href="#Tool & Framework">Tool & Framework</a></li>
    <li><a href="#Project Setup">Project Setup</a></li>
    <li><a href="#Design Pattern">Design Pattern</a></li>
    <li><a href="#Dependency">Dependency</a></li>
    <li><a href="#Contributing">Contributing</a></li>
  </ol>
</details>

# Getting Started
The E Movie displays movie catelog using TMDB api.It's implemented using infinite scrolling technique in UICollectionView. Details screen display movie description.  

## Tool & Framework
Xcode(v13.4.1) , Combine, SDWebImage

## Project Setup
To keep all those hundreds of source files from ending up in the same directory I use below project structure.

    ├─ Utilities
    ├─ Service URL
    ├─ Service
    ├─ Storyboard
    ├─ LifeCycle
    ├─ Helpers
    ├─ Scenes ├─ View
              ├─ ViewModel
              ├─ Model
    
## Design Pattern
I use Model View View-Model (MVVM)design pattern. MVVM is basically a UI Based Design Pattern. The main object of MVVM is to provide a rich UI, testability features, code more reusability and complex data binding. It helps to improve the separation of the business and presentation layers without any direct communication between each other.

## Dependency
I use swift package manager to add dependencies like SDWebImage.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

