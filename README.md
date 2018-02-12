# CrimeStats
R code and datasets for analyzing crime data in the Houston area

For HPD data:

    Read in data for district "a"
        ReadHPDdata_1a.Rmd
        ReadHPDdata_2a.Rmd

    Output files from read and clean exercise
        District1aCleanData.rds
        District2aCleanData.rds

    Geocode district data and store the Address/Lat/Long data in a file
        Geocoding.Rmd  - code
        GeoTable.rds   - data

    Create polygon files for census blocks, zip codes, neighborhoods, beats
    and intersect them with the GeoTable file. Then add back in the
    records from GeoTable that have incomplete coordinates, and save the
    result back to GeoTable.

        AddPolygons.Rmd
  
        Neighborhoods
            Neighborhoods.kml - output from Wikimapia
            Neighborhoods.gml - exploded output from ogr
            Nbhd_point.shp - ogl output of the point data (labels)
            Nbhd_line.shp - ogl output of the polygon data as lines
            
            NeighborhoodPolys.rds - cleaned R dataset of polygons
                    Name, descriptio
             
            Within the new GeoTable file, the neighborhood names are stored in
            the column Nbhd, separated by commas

        Zip Codes
            USCB_Zip_Codes_2010.gdb - input file downloaded from h-gac.com

            ZipCodes.rds - output transformed to 4326
                    Zip_Code, Shape_Length, Shape_Area

        Census data
            tl_2010_48_tabblock10.shp downloaded from Census site
            This is the entire state, so trimmed it to only contain
            Harris and adjacent counties - reducing size by almost
            a factor of 10.

            HouCensusPolys.rds - trimmed to Houston area, transformed to
            epsg 4326, contains County FIPS, Tract, Block, Name, etc.

            Also read in the population and housing data per block, and
            trimmed it back to Harris and adjacent counties. Stored in
            PopHou.rds

        Beat and District polygons
            Houston_Police_Beats.shp
            
            Houston_Police_Beats.rds - output file
