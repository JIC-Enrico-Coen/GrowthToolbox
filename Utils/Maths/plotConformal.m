function plotConformal( f, lo, hi, step )
%plotConformal( f, lo, hi, step )
%   f is a function from complex numbers to complex numbers.
%   lo and hi are two complex numbers defining a rectangle in the complex
%   plane.
%   step is a grid step size.
%   f is applied to the grid of complex numbers defined by lo, hi, and
%   step, and the transformed grid is plotted in the current figure (which
%   is first cleared).  The real lines of the grid are blue, the imaginary
%   lines are red.
%
%   Examples:
%
%   f = @(z)((z.^3)/3-z);
%   plotConformal(f, (1+2i)*0.8, -(1+2i)*0.8, 0.1);

    xb = sort( [real(lo), real(hi)] );
    yb = sort( [imag(lo), imag(hi)] );
    xs = linspace( xb(1), xb(2), round((xb(2)-xb(1))/step)+1 );
    ys = linspace( yb(1), yb(2), round((yb(2)-yb(1))/step)+1 );
    zs = repmat( xs', 1, length(ys) ) + 1i*repmat( ys, length(xs), 1 );
    ws = f(zs);
    
    cla;
    lx = reshape( [ws;nan(1,length(ys))], [], 1 );
    line( real(lx), imag(lx), 'Color', 'b' );
    ly = reshape( [permute(ws,[2 1]);nan(1,length(xs))], [], 1 );
    line( real(ly), imag(ly), 'Color', 'r' );
    axis equal
end
