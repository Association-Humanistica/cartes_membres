##install.packages("leaflet")
##install.packages("sp")
##install.packages("rgdal")
##install.packages("RColorBrewer")
##install.packages("leaflet.extras")
##install.packages("leaflet.minicharts")
##install.packages("htmlwidgets")
##install.packages("raster")
##install.packages("mapview")
##install.packages("leafem")

## Call the libraries
library(leaflet)
library(sp)
library(rgdal)
library(RColorBrewer)
library(leaflet.extras)
library(leaflet.minicharts)
library(htmlwidgets)
library(raster)
library(mapview)
library(leafem)
library(leafpop)
library(sf)
library(htmltools)

## PART 1 - IN THIS PART THE CODE READS THE FILES AND ATTRIBUTES COLORS AND ICONS TO ELEMENTS

## Read the shapefile
countries <- geojsonio::geojson_read("countries/countries.geojson", what = "sp")

## Create the palette of colors for the shapefiles
pal <- colorBin("YlOrRd", domain = countries$number)

## Read the csv
membres <- read.csv("data/membres.csv")
##projets <- read.csv("data/projets.csv")

## Create a html popup
content <- paste(sep = "<br/>",
                        paste0("<div class='leaflet-popup-scrolled' style='max-width:200px;max-height:200px'>"),
                        paste0("<b>", membres$name, " ", membres$surname, "</b>"),
                        paste0("<br>"),
                        paste0("Poste occupé :", " ", "<b>", membres$job, "</b>"),
                        paste0("<br>"),
                        paste0("Bio :", "<b>", membres$job, "</b>"),
                        paste0(membres$bio),
                        paste0("Link :", "<b>", membres$social, "</b>"),
                        ##paste0(membres$url),
                        paste0("</div>"))

## PART 2 - IN THIS PART THE CODE ADDS ELEMENT ON THE MAP LIKE POLYGONS, POINTS AND IMAGES.

m <- leaflet() %>%
  ## Basemap
  ##addTiles(tile) %>%
  addProviderTiles(providers$CartoDB.Positron)  %>%
  
  ## Add a zoom reset button
  addResetMapButton() %>%
  ## Add a Minimap to better navigate the map
  addMiniMap() %>%
  ## Add a coordinates reader
  leafem::addMouseCoordinates() %>%
  ## define the view
  setView(lng = -40.1113227933356, 
          lat = 28.09815143150374, 
          zoom = 2 ) %>%
  
  ## Add Polygon layer from the Geojson
  addPolygons(data = countries,
              fillColor = ~pal(countries$number),
              weight = 0.1,
              color = "brown",
              dashArray = "3",
              opacity = 0.7,
              stroke = TRUE,
              fillOpacity = 0.5,
              smoothFactor = 0.5,
              group = "Countries",
              label = ~paste(name, ": ", number, " de membres", sep = ""),
              highlightOptions = highlightOptions(
                weight = 0.6,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE))%>%
  
  ## Add a legend with the occurrences of the toponyms according to the macro areas
  addLegend("bottomleft", 
            pal = pal, 
            values = countries$number,
            title = "Membres by country:",
            labFormat = labelFormat(suffix = " Membres"),
            opacity = 0.5,
            group = "Countries") %>%
  
  ## Add Markers with clustering options
  addAwesomeMarkers(data = membres, 
                    lng = ~lng,
                    lat = ~lat, 
                    popup = c(content), 
                    group = "Membres",
                    options = popupOptions(maxWidth = 100, maxHeight = 150), 
                    clusterOptions = markerClusterOptions())%>%
  
  ## Add Heatmap of the  dataset
  addHeatmap(data = membres,
             lng = ~lng,
             lat = ~lat, 
             group = "Heatmap",
             blur = 8, 
             max = 0.5, 
             radius = 10) %>%
  
  ## Add a legend with the credits
  addLegend("topright", 
            
            colors = c("trasparent"),
            labels=c("Association Francophone des Humanités Numériques (https://www.humanisti.ca/)"),
            
            title="Carte des membres de Humanistica") %>%
  
 
  ## PART 3 - IN THIS PART THE CODE MANAGE THE LAYERS' SELECTOR
  
  ## Add the layer selector which allows you to navigate the possibilities offered by this map
  
  addLayersControl(baseGroups = c("Membres",
                                  "Empty layer"),
                   
                   overlayGroups = c("Countries",
                                     "Heatmap"),
                   
                   options = layersControlOptions(collapsed = TRUE)) %>%
  
  ## Hide the layers that the users can choose as they like
  hideGroup(c("Empty",
              "Heatmap"))

## Show the map  
m

