# CrimeStats
R code and datasets for analyzing crime data in the Houston area

For HPD data:

    Read in data for districts
        ReadHPDdata_1a.Rmd
        ReadHPDdata_2a.Rmd
        ReadHPDdata_4f.Rmd
        ReadHPDdata_5f.Rmd
        ReadHPDdata_10h.Rmd

    Output files from read and clean exercise
        District1aCleanData.rds
        District2aCleanData.rds
        District4fCleanData.rds
        District5fCleanData.rds
        District10hCleanData.rds

    PremiseTable.rds -  translation table to go from large number of
                        premise names to a small number

    Geocode district data and store the Address/Lat/Long data in a file
        Geocoding.Rmd  - code
        GeoTable.rds   - data

    Create polygon files for census blocks, zip codes, neighborhoods, beats
    and intersect them with the GeoTable file. Then add back in the
    records from GeoTable that have incomplete coordinates, and save the
    result back to GeoTable.

        AddPolygons.Rmd - code
        AddPolygonsDocumentation.Rmd - code with small dataset and more explanation
        
  
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



<h4>Geocoding is hard</h4>

<p>
Started using Google, but with a few hundred thousand addresses, the 2500 per day limit was a killer. So instead used the census bureau geocoder, which got about 2/3 of the addresses okay. The biggest problem with teh census geocoder I found was that it would basically ignore the direction indicator on a street name (N,S,E,W) and sometimes give the wrong location (S Shepherd instead of N Sheperd), and claim tha it had a perfect match! So I did a double check on the matches myself and only accepted those that that claimed a perfect match and also regurgitated a street name that matched the input. Took the 1/3 that failed that process, and fed those to Google (some 30,000 addresses). Two weeks later, I had matches for those - and a zip code. Now I could go back and use the Google addresses, the census addresses, and geocode with the census for the other end of the block.
</p>

<ol>
<li>PrepCensusGeocode.R - read in all the files and create files suitable for the census batch geocoder, each file with 10,000 records.</li>
<li>Run geocoder batch: https://geocoding.geo.census.gov/geocoder/locations/addressbatch?form </li>
<li>ReadCensusGeocode.R - read in the output from the census batch geocoder, export matches to Master_Geocode.rds, export non-matches to partialgeocode.rds for later input to google</li>
<li>GetZipcode.r - geocode using Google up to the daily limit. Save output to GoogleLocationsMaster.rds</li>
<li>MakeBlockCenter.Rmd - Read in both geocoded files, use best address and add 99 to address, then geocode that address with census tool, average location to get block center, and save to GeocodeMaster.rmd</li>
</ol>
