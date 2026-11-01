-- Original UI behavior, rewritten with meaningful local names.
-- Source: functions 242 (control creation) and 293 (visibility callback).
-- group and section_selector belong to Outlaw's custom UI wrapper.
-- Native ui.new_combobox references do not provide these object methods.

local experimental_predict = {}

function experimental_predict.create(group, section_selector, settings)
    local predict = group:combo(
        "\aFF6363FFExperimental \aCDCDCDFFPredict",
        "Off",
        "High Ping > 60",
        "Low Ping < 45"
    )

    section_selector:callback(function(current_section)
        predict:visibility(current_section:get() == "Rage Bot")
    end, true)

    if settings then
        settings.predict = predict
    end

    -- The source contains no callback that applies the selected mode.
    return predict
end

return experimental_predict
