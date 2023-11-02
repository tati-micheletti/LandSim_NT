studyAreaGenerator <- function(url = NULL, destPath = NULL, Crs = NULL, large = FALSE){
  if (is.null(url))
    url <- "https://drive.google.com/open?id=1fYvNPwovjNtTABoGcegrvdFGkNfCUsxf"
  if (is.null(destPath))
    destPath <- tempdir()
  if (is.null(Crs))
    Crs <- "PROJCRS[\"unknown\",\n    BASEGEOGCRS[\"unknown\",\n        DATUM[\"Unknown_based_on_GRS80_ellipsoid\",\n            ELLIPSOID[\"GRS 1980\",6378137,298.257222101004,\n                LENGTHUNIT[\"metre\",1],\n                ID[\"EPSG\",7019]]],\n        PRIMEM[\"Greenwich\",0,\n            ANGLEUNIT[\"degree\",0.0174532925199433,\n                ID[\"EPSG\",9122]]]],\n    CONVERSION[\"Lambert Conic Conformal (2SP)\",\n        METHOD[\"Lambert Conic Conformal (2SP)\",\n            ID[\"EPSG\",9802]],\n        PARAMETER[\"Latitude of false origin\",0,\n            ANGLEUNIT[\"degree\",0.0174532925199433],\n            ID[\"EPSG\",8821]],\n        PARAMETER[\"Longitude of false origin\",-95,\n            ANGLEUNIT[\"degree\",0.0174532925199433],\n            ID[\"EPSG\",8822]],\n        PARAMETER[\"Latitude of 1st standard parallel\",49,\n            ANGLEUNIT[\"degree\",0.0174532925199433],\n            ID[\"EPSG\",8823]],\n        PARAMETER[\"Latitude of 2nd standard parallel\",77,\n            ANGLEUNIT[\"degree\",0.0174532925199433],\n            ID[\"EPSG\",8824]],\n        PARAMETER[\"Easting at false origin\",0,\n            LENGTHUNIT[\"metre\",1],\n            ID[\"EPSG\",8826]],\n        PARAMETER[\"Northing at false origin\",0,\n            LENGTHUNIT[\"metre\",1],\n            ID[\"EPSG\",8827]]],\n    CS[Cartesian,2],\n        AXIS[\"easting\",east,\n            ORDER[1],\n            LENGTHUNIT[\"metre\",1,\n                ID[\"EPSG\",9001]]],\n        AXIS[\"northing\",north,\n            ORDER[2],\n            LENGTHUNIT[\"metre\",1,\n                ID[\"EPSG\",9001]]]]"
  studyArea <- reproducible::prepInputs(url = url,
                                        targetFile = "edehzhie_boundary.shp",
                                        destinationPath = destPath,
                                        fun = "terra::vect",
                                        userTags = c("objectName:studyArea"))
  studyArea <- reproducible::projectTo(from = studyArea, projectTo = Crs)
  if (large){
    studyArea <- terra::buffer(x = studyArea, width = 20000)
    message(crayon::green("Study area large sucessfully created!"))
  } else {
    message(crayon::green("Study area sucessfully created!"))
  }
  return(studyArea)
}
rtmGenerator <- function(url = NULL, destPath = NULL, Crs = NULL, sA = NULL){
  if (is.null(url))
    url <- "https://drive.google.com/file/d/11yCDc2_Wia2iw_kz0f0jOXrLpL8of2oM"
  if (is.null(destPath))
    destPath <- tempdir()
  RTM <- reproducible::prepInputs(url = url,
                                  destinationPath = destPath,
                                  studyArea = sA,
                                  fun = "terra::rast",
                                  userTags = c("objectName:RTM"))
  message(crayon::green("RTM sucessfully created!"))
  return(RTM)
}
sppEquiv_CA <- function(runName){
  data("sppEquivalencies_CA", package = "LandR")
  sppEquivCol <- runName
  
  # Make NWT spp equivalencies
  sppEquivalencies_CA[, paste0(runName) := c(Betu_Pap = "Betu_Pap",
                                             Lari_Lar = "Lari_Lar",
                                             Pice_Gla = "Pice_Gla",
                                             Pice_Mar = "Pice_Mar",
                                             Pinu_Ban = "Pinu_Ban",
                                             Popu_Tre = "Popu_Tre")[Boreal]]
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!is.na(get(runName))]
  sppEquivalencies_CA$EN_generic_short <- sppEquivalencies_CA[[paste0(runName)]]
  return(sppEquivalencies_CA)
}
