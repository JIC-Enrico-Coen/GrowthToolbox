function y = myround( x, varargin )
%y = myround( x, varargin )
%   An emulation of the round() function as present in Matlab 2015a onwards
%   which takes up to three arguments.  In some earlier versions, round()
%   takes only one argument.  2015a help text follows:
%
% round  rounds towards nearest decimal or integer
%  
%     round(X) rounds each element of X to the nearest integer.
%     
%     round(X, N), for positive integers N, rounds to N digits to the right
%     of the decimal point. If N is zero, X is rounded to the nearest integer.
%     If N is less than zero, X is rounded to the left of the decimal point.
%     N must be a scalar integer.
%  
%     round(X, N, 'significant') rounds each element to its N most significant
%     digits, counting from the most-significant or left side of the number. 
%     N must be a positive integer scalar.
%  
%     round(X, N, 'decimals') is equivalent to round(X, N).
%  
%     For complex X, the imaginary and real parts are rounded independently.
%  
%     Examples
%     --------
%     % Round pi to the nearest hundredth
%     >> round(pi, 2)
%          3.14
%  
%     % Round the equatorial radius of the Earth, 6378137 meters,
%     % to the nearest kilometer.
%     round(6378137, -3)
%          6378000
%  
%     % Round to 3 significant digits
%     format shortg;
%     round([pi, 6378137], 3, 'significant')
%          3.14     6.38e+06
%  
%     If you only need to display a rounded version of X,
%     consider using fprintf or num2str:
%  
%     fprintf('%.3f\n', 12.3456)
%          12.346 
%     fprintf('%.3e\n', 12.3456)
%          1.235e+01
%  
%    See also floor, ceil, fprintf.
% 
%     Other functions named round
% 
%     Reference page in Help browser
%        doc round

    if nargin < 2
        y = round(x);
    elseif nargin >= 2
        n = varargin{1};
        sigfigs = (nargin >= 3) && strcmp( varargin{2}, 'significant' );
        if sigfigs
            d = fix(log10(abs(x)));
            n = n - d - 1;
            y = round( x.*(10.^n) ) .* (10.^(-n));
        else
            y = round( x*(10^n) ) * (10^(-n));
        end
    end
end
