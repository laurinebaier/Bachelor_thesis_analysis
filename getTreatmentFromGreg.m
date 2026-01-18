function treatmentName = getTreatmentFromGreg(gregName)
    num = str2double(gregName(5:6));
    if num >= 1 && num <= 10
        treatmentName = 'control_locust_saline';
    elseif num >= 11 && num <= 26
        treatmentName = 'methoprene';
    elseif num >= 27 && num <= 42
        treatmentName = 'precocene_II';
    elseif num >= 43 && num <= 54
        treatmentName = 'control_untreated';
    elseif num >= 85 && num <= 94
        treatmentName = 'control_DMSO';
    else
        treatmentName = '';
    end
end
