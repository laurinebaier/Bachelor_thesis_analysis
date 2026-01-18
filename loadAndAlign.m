function [pos_x_aligned, pos_y] = loadAndAlign(csvFile, matFile)
    % Trackingdaten einlesen
    tTab = readtable(csvFile);
    % Annotation laden
    S = load(matFile);
    A = S.Annotation;

    % Arena-Mitte und Radius
    roiPar = A.ROI.Par;            % [x_center, y_center, radius]
    xmid   = roiPar(1);
    center = roiPar(1:2);
    r      = roiPar(3);

    % Punkte außerhalb des Arenakreises entfernen
    dist2  = (tTab.pos_x - center(1)).^2 + (tTab.pos_y - center(2)).^2;
    inside = dist2 <= r^2;
    tTab   = tTab(inside, :);

    % Shelter-Kreise (für Orientierung / empty-Seite)
    parShelter = A.Masks.Circular;
    empty_x    = parShelter(1,1);

    % Ausrichtung: empty immer links
    if empty_x > xmid
        % Spiegelung an der vertikalen Linie x = xmid
        pos_x_aligned = xmid - (tTab.pos_x - xmid);
    else
        pos_x_aligned = tTab.pos_x;
    end

    % y-Koordinate unverändert
    pos_y = tTab.pos_y;
end
