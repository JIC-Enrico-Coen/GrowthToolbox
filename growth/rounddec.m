function y = rounddec(x, n)

% stolen from Peter J. Acklam 
% Erika 30.01.2009

% round any number x to the by n specified decimal places.  

f = 10.^n;
y = round(x.*f)./f;
