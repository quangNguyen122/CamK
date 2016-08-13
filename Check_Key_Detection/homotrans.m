function P = homotrans(p, F)
% HOMOTRANS maps p to P throug homographic transformation give coefficient
% vector a
%
% In:
%   p [x x y]:  pixel in original coordinate
%   F <8 x 1>: transform coefficient
% 
% Out:
%
%   P [x x Y]:  pixel in mapped coordinate

x = p(1); y = p(2);
X = (F(1)*x + F(2)*y + F(3))/(F(7)*x + F(8)*y + 1);
Y = (F(4)*x + F(5)*y + F(6))/(F(7)*x + F(8)*y + 1);

P = [X Y];