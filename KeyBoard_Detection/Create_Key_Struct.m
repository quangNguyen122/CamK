function K = Create_Key_Struct(LayoutPoints, FramePoints, npts, K_Layout)
% Input
%   LayoutPoints : <4 x 2> 4 center Points of Layout PDF
%   FramePoints : <4 x 2> 4 center Points of Video Frame detected
%   npts (int): 4, 8, 12 homography point
%   K_Layout: <struct> key struct of Layout PDF
% Output
%   K : <struct> Key struct of Video Frame
%       td : 4 coordinate - name : 1 -> 64 - area : key's area
% Note : Remember load Key Struct Layout before run this function and set
% path for 2 folders

LP = LayoutPoints;
UP = FramePoints;

% adjust Inf Point 1  - Top Down

% Move B to left-right
AB = UP(2,:) - UP(1,:);
ratio = 1.01;
AG = AB * ratio;
G = AG + UP(1,:);
UP(2,:) = G;

% Move A to left-right
BA = UP(1,:) - UP(2,:);
ratio = 0.98;
BG = BA * ratio;
G = BG + UP(2,:);
UP(1,:) = G;

% adjust Inf Point 2 - Left Right

% Move A up-down
DA = UP(1,:) - UP(4,:);
ratio = 1.02;
DG = DA * ratio;
G = DG + UP(4,:);
UP(1,:) = G;

% Move B up-down
CB = UP(2,:) - UP(3,:);
ratio = 1.04;
CG = CB * ratio;
G = CG + UP(3,:);
UP(2,:) = G;

% Move D up-down
AD = UP(4,:) - UP(1,:);
ratio = 0.96;
AE = AD * ratio;
D = AE + UP(1,:);
UP(4,:) = D;

% Move C up-down
BC = UP(3,:) - UP(2,:);
ratio = 0.96;
BF = BC * ratio;
F = BF + UP(2,:);
UP(3,:) = F;
oP = LP;nP = UP;


if npts >=8
    % find 4 mid point
    P1 = zeros(4,2);
    P2 = zeros(4,2);
    for i = 1 : 3
        p1 = (oP(i,:) + oP(i+1,:))/2;
        p2 = (nP(i,:) + nP(i+1,:))/2;
        P1(i,:) = p1;
        P2(i,:) = p2;
    end
    p1 = (oP(4,:) + oP(1,:))/2;
    p2 = (nP(4,:) + nP(1,:))/2;
    P1(4,:) = p1;
    P2(4,:) = p2;
    oP = [oP;P1];
    nP = [nP;P2];
    if npts >= 12
        % % mid point of midpoint
        P1n = zeros(4,2);
        P2n = zeros(4,2);
        for i = 1 : 3
            p1 = (P1(i,:) + P1(i+1,:))/2;
            p2 = (P2(i,:) + P2(i+1,:))/2;
            P1n(i,:) = p1;
            P2n(i,:) = p2;
        end
        p1 = (P1(4,:) + P1(1,:))/2;
        p2 = (P2(4,:) + P2(1,:))/2;
        P1n(4,:) = p1;
        P2n(4,:) = p2;
        oP = [oP;P1n];
        nP = [nP;P2n];
        if npts >= 16
            % % mid point of midpoint
            P1 = zeros(4,2);
            P2 = zeros(4,2);
            for i = 1 : 3
                p1 = (P1n(i,:) + P1n(i+1,:))/2;
                p2 = (P2n(i,:) + P2n(i+1,:))/2;
                P1(i,:) = p1;
                P2(i,:) = p2;
            end
            p1 = (P1n(4,:) + P1n(1,:))/2;
            p2 = (P2n(4,:) + P2n(1,:))/2;
            P1(4,:) = p1;
            P2(4,:) = p2;
            oP = [oP;P1];
            nP = [nP;P2];
            if npts >= 20
                % % mid point of midpoint
                P1n = zeros(4,2);
                P2n = zeros(4,2);
                for i = 1 : 3
                    p1 = (P1(i,:) + P1(i+1,:))/2;
                    p2 = (P2(i,:) + P2(i+1,:))/2;
                    P1n(i,:) = p1;
                    P2n(i,:) = p2;
                end
                p1 = (P1(4,:) + P1(1,:))/2;
                p2 = (P2(4,:) + P2(1,:))/2;
                P1n(4,:) = p1;
                P2n(4,:) = p2;
                oP = [oP;P1n];
                nP = [nP;P2n];
            end
        end
    end
end

H = homography(oP',nP');
K = {};
for i = 1 : 64
    AP = zeros(4,2);
    for j = 1 : 4
        AP(j,:) = homtrans(H,K_Layout{i}.td(j,:)');
        K{i}.td(j,:) = [AP(j,1) AP(j,2)];
    end
    K{i}.name = i;
    K{i}.area = polyarea(K{i}.td(:,1),K{i}.td(:,2));
    K{i}.td(5,:) = [mean(AP(:,1)) mean(AP(:,2))];
end