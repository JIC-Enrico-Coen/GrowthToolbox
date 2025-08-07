function c = cns2rgb( s )
%c = cns2rgb( s )
%   Convert a CNS color name to RGB.
%
%   Case is ignored. The string S is expected to consist of words from the
%   CNS separated by spacing.
%
%   The CNS is specified by the following grammar (from
%   https://en.wikipedia.org/wiki/Color_Naming_System):
%
%     named-color     := gray-color | chromatic-color
% 
%     gray-color      := 'black' | 'white' | [lightness] gray
%     gray            := 'gray' | 'grey'
% 
%     chromatic-color := ( [ tint | shade ] | [ lightness | saturation ] ) hue
%     tint            := 'whitish' | 'pale' | 'brilliant' | 'vivid'
%     shade           := 'blackish' | 'dim' | 'deep' | 'vivid'
%     saturation      := 'grayish' | 'moderate' | 'strong' | 'vivid'
%     lightness       := 'moderate' | ['very'] ( 'dark' | 'light' )
%     hue             := [splash-color] base-color | ( base-color '-' base-color )
%     base-color      := 'red' | 'orange' | 'brown' | 'yellow' | 'green' | 'blue' | 'purple'
%     splash-color    := 'reddish' | 'orangish' | 'brownish' | 'yellowish' | 'greenish' | 'bluish' | 'purplish'


    % Convert to lower case.
    s = lower( s );
    
    % Remove leading and trailing space, then split at the remaining
    % spaces.
    s = regexprep( s, '-', ' - ' );
    s = regexprep( s, '^\s+', '' );
    s = regexprep( s, '\s+$', '' );
    s = regexprep( s, '\s+', ' ' );
    s = regexprep( s, 'very light', 'verylight' );
    s = regexprep( s, 'very dark', 'verydark' );
    words = regexp( s, '([\w-]+)', 'match' );
    if isempty( words )
        c = [];
        return;
    end
    numTokens = length( words );
    
    
%     bws = { 'black', 'white' };
    grays = { 'gray', 'grey', 'black', 'white' };
    grayValues = [ 0.5, 0.5, 0, 1 ];
    tints = { 'whitish', 'pale', 'brilliant', 'vivid' };
    shades = { 'blackish', 'dim', 'deep', 'vivid' };
    saturations = { 'grayish', 'moderate', 'strong', 'vivid' };
    basecolors = { 'red', 'orange', 'brown', 'yellow', 'green', 'blue', 'purple' };
    baseColorValues = [ 1 0 0;
                        1 0.5 0;
                        0.3 0.15 0;
                        1 1 0;
                        0 1 0;
                        0 0 1;
                        1 0 1 ]/2;
    splashcolors = { 'reddish', 'orangish', 'brownish', 'yellowish', 'greenish', 'bluish', 'purplish' };
    lightnesses = { 'verydark', 'dark', 'moderate', 'light', 'verylight' };
    lightnessValues = [ 1 2 3 4 5 ]/6;
    
    % Get the lightness modifier, if any.
    currentToken = 1;
    lightnessindex = whichString( words{currentToken}, lightnesses );
    if lightnessindex ~= 0
        lightnessValue = lightnessValues( lightnessindex );
        currentToken = currentToken+1;
    end
    
    % Handle grayscale colors.
    [grayindex,grayness] = whichString( words{currentToken}, grays );
    isGray = ~isempty( grayness );
    if isGray
        currentToken = currentToken+1;
        % Check that's all.
        baseGray = grayValues(grayindex);
        c = lighten( [ baseGray, baseGray, baseGray ], lightnessValue );
        return;
    end
    
    % Get the tint, shade, or saturation. At most one of these can occur.
%     haveTint = false;
    tintindex = 0;
%     haveShade = false;
    shadeindex = 0;
%     haveSaturation = false;
    saturationindex = 0;
    
    if lightnessindex==0
        tintindex = whichString( words{currentToken}, tints );
        if tintindex ~= 0
            currentToken = currentToken+1;
            % Check not beyond the end.
        else
            shadeindex = whichString( words{currentToken}, shades );
            if shadeindex ~= 0
                currentToken = currentToken+1;
                % Check not beyond the end.
            else
                saturationindex = whichString( words{currentToken}, saturations );
                if saturationindex ~= 0
                    currentToken = currentToken+1;
                    % Check not beyond the end.
                end
            end
        end
    end
    
    % What remains is the hue.
    % The next token must be either a basecolor or a splashcolor.
    
    basecolor2index = 0;
    baseColor2 = '';
    splashcolor2index = 0;
    splashcolor2 = '';
    baseRGB = [];
    base2RGB = [];
    splashRGB = [];
    
    basecolorindex = whichString( words{currentToken}, basecolors );
    if basecolorindex==0
        % Must be a splashcolor.
        [splashcolorindex,splashColor] = whichString( words{currentToken}, splashcolors );
        if isempty( splashColor )
            % Error.
        else
            currentToken = currentToken+1;
            % Check not beyond end of spec.
            splashRGB = baseColorValues( splashcolorindex, : );
            % The next token must be the base color.
            basecolorindex = whichString( words{currentToken}, basecolors );
            % Check is not 0;
            baseRGB = baseColorValues( basecolorindex, : );
            currentToken = currentToken+1;
            % Check this is the end of the spec.
        end
    else
        baseRGB = baseColorValues( basecolorindex, : );
        currentToken = currentToken+1;
        % Check not beyond end of spec.
        % Either there is no next token or the next token is a '-'.
        if currentToken > numTokens
            % No more to read.
        else
            if strcmp( words{currentToken}, '-' )
                currentToken = currentToken+1;
                % Check not beyond end of spec.
                [basecolor2index,baseColor2] = whichString( words{currentToken}, basecolors );
                if ~isempty( baseColor2 )
                    currentToken = currentToken+1;
                    % Check not beyond end of spec.
                    base2RGB = baseColorValues( basecolor2index, : );
                end
            else
                % Error: more tokens after end of color spec.
            end
        end
    end
    
    % Check we are at the end of the spec.
    
    % Now we must combine the results. At this point baseRGB must be
    % nonempty.
    
    c = baseRGB;
    if ~isempty( base2RGB )
        c = (c + base2RGB)/2;
    elseif ~isempty( splashRGB )
        c = c*0.75 + splashRGB*0.25;
    end
    
    % Now apply tint, shade, lightness, and saturation.
    
    % PROBLEM: tint, shade, and saturation all have a 'vivid' value.
    % saturation and lightness both have a 'moderate' value.
    
    % NOT IMPLEMENTED.
    switch tintindex
        case 0
            % No tint.
        case 1
            % whitish
            c = 0.25*c + 0.75;
        case 2
            % pale
            c = 0.5*c + 0.5;
        case 3
            % brilliant
        case 4
            % vivid
        otherwise
            % ignore
    end
    
    % NOT IMPLEMENTED.
    switch shadeindex
        case 0
            % No shade
        case 1
            % blackish
            c = 0.5*c
        case 2
            % dim
            c = 0.25*c
        case 3
            % deep
            % Increase saturation but not brightness.
            hi = max(c);
            c = rescaleInterval( c, [min(c), hi], [0, hi*0.75], 0.5 );
        case 4
            % vivid
            % Like 3 but to the max.
            hi = max(c);
            c = rescaleInterval( c, [min(c), hi], [0, hi*0.5], 1 );
        otherwise
            % Ignore.
    end
    
    % NOT IMPLEMENTED.
    switch saturationindex
        case 0
            % No saturation
        case 1
            % grayish
        case 2
            % moderate
        case 3
            % strong
        case 4
            % vivid
        otherwise
            % Ignore.
    end
    
    if lightnessindex ~= 0
        lightnessNumber = lightnessValues( lightnessindex );
        c = lighten( c, lightnessNumber );
    end
    
    
    xxxx = 1;

% named-color     := gray-color | chromatic-color
% 
% gray-color      := 'black' | 'white' | [lightness] gray
% gray            := 'gray' | 'grey'
% 
% chromatic-color := ( [ tint | shade ] | [ lightness | saturation ] ) hue
% tint            := 'whitish' | 'pale' | 'brilliant' | 'vivid'
% shade           := 'blackish' | 'dim' | 'deep' | 'vivid'
% saturation      := 'grayish' | 'moderate' | 'strong' | 'vivid'
% lightness       := 'moderate' | ['very'] ( 'dark' | 'light' )
% hue             := [splash-color] base-color | ( base-color '-' base-color )
% base-color      := 'red' | 'orange' | 'brown' | 'yellow' | 'green' | 'blue' | 'purple'
% splash-color    := 'reddish' | 'orangish' | 'brownish' | 'yellowish' | 'greenish' | 'bluish' | 'purplish'
end

function c = rescaleInterval( c, oldrange, newrange, amount )
    a = newrange(2) - oldrange(2);
    b = -(newrange(1) - oldrange(1));
    if (a==0) && (b==0)
        return;
    end
    ab = a+b;
    a = a/ab;
    b = b/ab;
    centre = a * oldrange(1) + b * oldrange(2);

    maxscalefactor = (newrange(2)-newrange(1)) / (oldrange(2)-oldrange(1));
    scalefactor = maxscalefactor * amount + (1-amount);
    c = (c-centre)*scalefactor + centre;
end

function c = lighten( c, lightness )
    if lightness < 0.5
        l = 2*lightness;
        c = c*l;
    elseif lightness > 0.5
        l = 2*(1 - lightness);
        c = l + c*(1-l);
    end
end

function [si,smatch] = whichString( s, ss )
%si = whichString( s, ss )
%   S is a string and SS a cell array of strings.
%   Return the index of the first string in SS that S is equal to, and that
%   string. If S is not find on SS, return 0 and the empty string.

    cmps = strcmp( s, ss );
    si = find( cmps, 1 );
    if isempty( si )
        si = 0;
        smatch = '';
    else
        smatch = ss{si};
    end
end
