%CONVHULL Convex hull of a set of points in 2D/3D space
%   CONVHULL returns the convex hull of a set of points in 2D/3D space.
%
%   K = CONVHULL(X,Y) returns the 2D convex hull of the points (X,Y), where 
%   X and Y are column-vectors. The convex hull K is expressed in terms of 
%   a vector of point indices arranged in a counter-clockwise cycle around 
%   the hull.
%
%   K = CONVHULL(X,Y,Z) returns the 3D convex hull of the points (X,Y,Z), 
%   where X, Y, and Z are column-vectors. K is a triangulation representing
%   the boundary of the convex hull. K is of size mtri-by-3, where mtri is 
%   the number of triangular facets. That is, each row of K is a triangle 
%   defined in terms of the point indices.
%
%   K = CONVHULL(X) returns the 2D/3D convex hull of the points X. This 
%   variant supports the definition of points in matrix format. X is of 
%   size mpts-by-ndim, where mpts is the number of points and ndim is the 
%   dimension of the space where the points reside, 2 <= ndim <= 3. 
%   The output facets are equivalent to those generated by the 2-input or 
%   3-input calling syntax.
%
%   K = CONVHULL(...,'simplify', logicalvar) provides the option of
%   removing vertices that do not contribute to the area/volume of the
%   convex hull, the default is false. Setting 'simplify' to true returns
%   the topology in a more concise form.
%
%   [K,V] = CONVHULL(...) returns the convex hull K and the corresponding 
%   area/volume V bounded by K.
%
%   Example 1:
%      x = rand(20,1);
%      y = rand(20,1);
%      plot(x,y, '.');
%      k = convhull(x,y)
%      hold on, plot(x(k), y(k), '-r'), hold off
%
%   Example 2:
%      [x,y,z] = meshgrid(-2:1:2, -2:1:2, -2:1:2);
%      x = x(:); y = y(:); z = z(:);
%      K1 = convhull(x,y,z);
%      subplot(1,2,1);
%      trisurf(K1,x,y,z, 'Facecolor','cyan'); axis equal;
%      title(sprintf('Convex hull with simplify\nset to false'));
%      K2 = convhull(x,y,z, 'simplify',true);
%      subplot(1,2,2);
%      trisurf(K2,x,y,z, 'Facecolor','cyan'); axis equal;
%      title(sprintf('Convex hull with simplify\nset to true'));
%
%   See also DelaunayTri, TriRep, TRISURF, INPOLYGON, CONVHULLN, DELAUNAY, 
%            VORONOI, POLYAREA.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.20.4.12 $  $Date: 2010/02/25 08:10:16 $
%   Built-in function.




