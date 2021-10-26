function [d,maxabsstretch,maxrelstretch,stretches] = springdisplacementR0( nodes, edgeends, restlengths, springconst, dt )
%d = springdisplacementR0( nodes, edgeends, restlengths, springconst, dt )
%   Given a set of balls and springs described by NODES, EDGEENDS,
%   RESTLENGTHS, and SPRINGCONST, calculate the displacement of the balls
%   in time DT, assuming that they are immersed in aviscous medium in which
%   the effect of a constant force is to produce a constant velocity equal
%   to that force.
%   The midpoint method is used for the numerical integration.

    [d0,stretches] = springforces2D( nodes, edgeends, restlengths, springconst );
    n1 = nodes + d0*dt;
    d1 = springforces2D( n1, edgeends, restlengths, springconst );
    d = (d0+d1)*(dt/2);
    maxabsstretch = max(abs(stretches));
    maxrelstretch = max(abs(stretches./restlengths));
end

