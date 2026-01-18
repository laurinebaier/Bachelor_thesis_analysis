function treatmentName = getTreatmentFromSoli(soliName)
    num = str2double(soliName(5:6));
    if num >= 1 && num <= 10
        treatmentName = 'control_locust_saline';
    elseif num >= 11 && num <= 22
        treatmentName = 'methoprene';
    elseif num >= 27 && num <= 38
        treatmentName = 'precocene_II';
    elseif num >= 85 && num <= 96
        treatmentName = 'control_DMSO';
    else
        treatmentName = '';
    end
end
