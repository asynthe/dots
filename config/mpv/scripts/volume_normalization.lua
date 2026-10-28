local index = 5

local filters = {
    { af = "lavfi=[loudnorm=I=-30:TP=-3:LRA=4]", msg = "🔈 Background volume normalization ON" },
    { af = "lavfi=[loudnorm=I=-15:TP=-3:LRA=4]", msg = "🔊 Volume normalization ON" },
    { af = "lavfi=[loudnorm=I=-16:TP=-3:LRA=4]", msg = "🔊 Volume normalization TESTING 1" },
    { af = "lavfi=[dynaudnorm=f=75:g=25:p=0.55]", msg = "🔊 Volume normalization TESTING 2" },
    {
        af = "lavfi='pan=stereo|c0=FC+LFE+FL+BL+SL|c1=FC+LFE+FR+BR+SR,loudnorm=I=-14:LRA=1:tp=-1:linear=false:dual_mono=true'",
        msg = "🔊 Volume normalization TESTING 3",
    },
    { af = "anull", msg = "🔇 Audio filters OFF" },
}

-- Aplica el filtro inicial silenciosamente al cargar un archivo
mp.register_event("file-loaded", function()
    mp.set_property("af", filters[index].af)
end)

-- Cambia de filtro con "n" y muestra el mensaje correspondiente
function cycle_audio_filter()
    index = index + 1
    if index > #filters then
        index = 1
    end
    mp.set_property("af", filters[index].af)
    mp.osd_message(filters[index].msg, 2.0)
end

mp.add_key_binding("n", "cycle-audio-filter", cycle_audio_filter)
