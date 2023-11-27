getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

getOrUpdatePkg("Require", "0.3.1.9015")
getOrUpdatePkg("SpaDES.project", "0.0.8.9023")

################### RUNAME

if (SpaDES.project::user("tmichele")) setwd("~/projects/LandSim_NT/")

################ SPADES CALL
out <- SpaDES.project::setupProject(
  runName = "LandSim_NT",
  paths = list(projectPath = runName,
               scratchPath = "~/scratch"),
  modules =
    file.path("PredictiveEcology",
              c(paste0(# development
                  c("canClimateData",
                    "Biomass_core",
                    "Biomass_speciesData",
                    "Biomass_borealDataPrep",
                    "Biomass_speciesFactorial",
                    # "Biomass_speciesParameters", # Stalls, and we don't need for now
                    "fireSense_dataPrepFit",
                    "fireSense_IgnitionFit",
                    "fireSense_EscapeFit",
                    "fireSense_SpreadFit",
                    "fireSense_dataPrepPredict",
                    "fireSense_IgnitionPredict",
                    "fireSense_EscapePredict",
                    "fireSense_SpreadPredict"),
                  "@development")#,
              # "canClimateData@usePrepInputs"
              )),
  functions = "tati-micheletti/LandSim_NT@main/R/outterFuns.R",
  options = list(spades.allowInitDuringSimInit = TRUE,
                 reproducible.cacheSaveFormat = "rds",
                 gargle_oauth_email = if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 SpaDES.project.fast = TRUE,
                 reproducible.inputPaths = if (user("tmichele")) "~/data" else NULL,
                 reproducible.useMemoise = TRUE),
  times = list(start = 2011,
               end = 2100),
  studyArea = reproducible::Cache(studyAreaGenerator,url = "https://drive.google.com/file/d/1RPfDeHujm-rUHGjmVs6oYjLKOKDF0x09", 
                                 archive = "NT1_BCR6.zip",
                                 targetFile = "NT1_BCR6.shp",
                                 destPath = paths[["inputPath"]]),
  rasterToMatch = reproducible::Cache(rtmGenerator, url = "https://drive.google.com/file/d/11yCDc2_Wia2iw_kz0f0jOXrLpL8of2oM",
                               sA = studyArea, 
                               destPath = paths[["inputPath"]]),
  studyAreaLarge = reproducible::Cache(studyAreaGenerator, url = "https://drive.google.com/file/d/1RPfDeHujm-rUHGjmVs6oYjLKOKDF0x09",
                                      archive = "NT1_BCR6.zip",
                                      targetFile = "NT1_BCR6.shp",
                                      large = TRUE, 
                                      destPath = paths[["inputPath"]]),
  rasterToMatchLarge = reproducible::Cache(rtmGenerator, sA = studyAreaLarge, 
                                    destPath = paths[["inputPath"]],
                                    large = TRUE, 
                                    tags = "RTMlarge"),
  sppEquiv = sppEquiv_CA(runName),
  # fireSense_spreadFormula = "~ 0 + youngAge + MDC + class2 + class3 + nonForest_highFlam + nonForest_lowFlam", # Being created by fireSense_dataPrepFit
  params = list(.globals = list(sppEquivCol = runName,
                                dataYear = "2011",
                                .plots = NA,
                                .plotInitialTime = NA,
                                .useCache = c(".inputObjects", "init")), # Cache seems to be working only for Biomass_speciesData, Biomass_speciesFactorial,Biomass_borealDataPrep, Biomass_core,canClimateData, fireSense_dataPrepFit, fireSense_SpreadFit, fireSense_dataPrepPredict
                fireSense_EscapePredict = list(.useCache = FALSE),
                fireSense_IgnitionPredict = list(.useCache = FALSE),
                fireSense_SpreadFit = list(# Values from WBI
                # maxAsymptote, hillSlope1, inflectionPoint1, MDC, youngAge, class2, class3, nonForest_highFlam, nonForest_lowFlam
                                           lower = c(0.25, 0.2, 0.1, c(0, rep(-4, times = 5))), 
                                           upper = c(0.276, 2, 4, c(4, 0, rep(4, times = 4)))),
                canClimateData = list(.runName = runName,
                                      climateGCM = "CanESM5",
                                      climateSSP = "370",
                                      historicalFireYears = 1991:2020)
  ),
  packages = c("googledrive", 'RCurl', 'XML', 'igraph', 'qs',
               "PredictiveEcology/LandR@development (>= 1.1.0.9074)",
               "PredictiveEcology/SpaDES.core@development (>= 2.0.3.9000)",
               "PredictiveEcology/reproducible@development (>= 2.0.10)",
               "PredictiveEcology/climateData@development (>= 1.0.4)",
               "PredictiveEcology/fireSenseUtils@development (>= 0.0.5.9053)"),
  useGit = "sub"
)

snippsim <- do.call(SpaDES.core::simInitAndSpades, out)
