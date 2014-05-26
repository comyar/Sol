//
//  Climacon.h
//  Copyright (c) 2014, Comyar Zaheri, http://comyar.io
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#pragma mark - Macros

// UIFont name of the Climacon font
#define CLIMACON_FONT @"Climacons-Font"


#pragma mark - Type Definitions

/**
 Contains the mappings from icon to character for the Climacons font by Adam Whitcroft.
 http://adamwhitcroft.com/climacons/font/
 */
typedef enum {
    ClimaconCloud                   = '!',
    ClimaconCloudSun                = '"',
    ClimaconCloudMoon               = '#',
    
    ClimaconRain                    = '$',
    ClimaconRainSun                 = '%',
    ClimaconRainMoon                = '&',
    
    ClimaconRainAlt                 = '\'',
    ClimaconRainSunAlt              = '(',
    ClimaconRainMoonAlt             = ')',

    ClimaconDownpour                = '*',
    ClimaconDownpourSun             = '+',
    ClimaconDownpourMoon            = ',',
    
    ClimaconDrizzle                 = '-',
    ClimaconDrizzleSun              = '.',
    ClimaconDrizzleMoon             = '/',
    
    ClimaconSleet                   = '0',
    ClimaconSleetSun                = '1',
    ClimaconSleetMoon               = '2',
    
    ClimaconHail                    = '3',
    ClimaconHailSun                 = '4',
    ClimaconHailMoon                = '5',
    
    ClimaconFlurries                = '6',
    ClimaconFlurriesSun             = '7',
    ClimaconFlurriesMoon            = '8',
    
    ClimaconSnow                    = '9',
    ClimaconSnowSun                 = ':',
    ClimaconSnowMoon                = ';',
    
    ClimaconFog                     = '<',
    ClimaconFogSun                  = '=',
    ClimaconFogMoon                 = '>',
    
    ClimaconHaze                    = '?',
    ClimaconHazeSun                 = '@',
    ClimaconHazeMoon                = 'A',
    
    ClimaconWind                    = 'B',
    ClimaconWindCloud               = 'C',
    ClimaconWindCloudSun            = 'D',
    ClimaconWindCloudMoon           = 'E',
    
    ClimaconLightning               = 'F',
    ClimaconLightningSun            = 'G',
    ClimaconLightningMoon           = 'H',
    
    ClimaconSun                     = 'I',
    ClimaconSunset                  = 'J',
    ClimaconSunrise                 = 'K',
    ClimaconSunLow                  = 'L',
    ClimaconSunLower                = 'M',
    
    ClimaconMoon                    = 'N',
    ClimaconMoonNew                 = 'O',
    ClimaconMoonWaxingCrescent      = 'P',
    ClimaconMoonWaxingQuarter       = 'Q',
    ClimaconMoonWaxingGibbous       = 'R',
    ClimaconMoonFull                = 'S',
    ClimaconMoonWaningGibbous       = 'T',
    ClimaconMoonWaningQuarter       = 'U',
    ClimaconMoonWaningCrescent      = 'V',
    
    ClimaconSnowflake               = 'W',
    ClimaconTornado                 = 'X',
    
    ClimaconThermometer             = 'Y',
    ClimaconThermometerLow          = 'Z',
    ClimaconThermometerMediumLoew   = '[',
    ClimaconThermometerMediumHigh   = '\\',
    ClimaconThermometerHigh         = ']',
    ClimaconThermometerFull         = '^',
    ClimaconCelsius                 = '_',
    ClimaconFahrenheit              = '\'',
    ClimaconCompass                 = 'a',
    ClimaconCompassNorth            = 'b',
    ClimaconCompassEast             = 'c',
    ClimaconCompassSouth            = 'd',
    ClimaconCompassWest             = 'e',
    
    ClimaconUmbrella                = 'f',
    ClimaconSunglasses              = 'g',
    
    ClimaconCloudRefresh            = 'h',
    ClimaconCloudUp                 = 'i',
    ClimaconCloudDown               = 'j'
} Climacon;
