------------------------------------------------------------------------
-- LIBRAIRIES
------------------------------------------------------------------------
require 'ltn12'
require 'socket.http'
local json = require("json")-- PAS NATIF SUR LA VERA

------------------------------------------------------------------------
-- FONCTION HTTP POST
------------------------------------------------------------------------
function posthttp(p_url,p_body)
local response_body = { }
local res, code, response_headers = socket.http.request
{
  url = p_url;
  method = "POST";
  headers =
  {
    ["Content-Type"] = "application/x-www-form-urlencoded";
    ["Content-Length"] = #p_body;
  };
  source = ltn12.source.string(p_body);
  sink = ltn12.sink.table(response_body);
}
return json.decode(table.concat(response_body),true)
end

------------------------------------------------------------------------
-- FONCTION ReadNetatmoAPI
------------------------------------------------------------------------
function ReadNetatmoAPI(lul_device)
        
    local request_body = "grant_type=password&client_id=" .. s_client_id .."&client_secret=" .. s_client_secret .. "&username=" .. s_username .. "&password=" .. s_password
    
    local reponsepost = posthttp("https://api.netatmo.net/oauth2/token",request_body)
    local access_token = reponsepost.access_token
    reponsepost = posthttp("https://api.netatmo.net/api/devicelist","access_token=" .. access_token)
    local module_interne = reponsepost.body.devices[1]._id
    local module_externe = reponsepost.body.modules[1]._id
    reponsepost = posthttp("https://api.netatmo.net/api/getmeasure","access_token=" ..access_token .."&device_id=" .. module_interne .. "&scale=max&type=Temperature,CO2,Humidity,Pressure,Noise&date_end=last")
    luup.log ("---------------")
    local temperature_interieure =reponsepost.body[1].value[1][1]
    local co2 =reponsepost.body[1].value[1][2]
    local humidite_interne =reponsepost.body[1].value[1][3]
    local pression =reponsepost.body[1].value[1][4]
    local bruit =reponsepost.body[1].value[1][5]
    luup.log(temperature_interieure)
    luup.log (co2)
    luup.log (humidite_interne)
    luup.log (pression)
    luup.log (bruit)
    reponsepost = posthttp("https://api.netatmo.net/api/getmeasure","access_token=" ..access_token .."&device_id=" .. module_interne .. "&module_id=" .. module_externe .. "&scale=max&type=Temperature,Humidity&date_end=last")
    local temperature_externe =reponsepost.body[1].value[1][1]
    local humidite_externe =reponsepost.body[1].value[1][2]
    luup.log(temperature_externe)
    luup.log (humidite_externe)
    luup.log ("---------------")

end

------------------------------------------------------------------------
-- FONCTION findChildOrCreate
------------------------------------------------------------------------

local function findChildrenOrCreates(lul_device)
    

    local lul_children = {}


	for k, v in pairs(luup.devices)
	do
        if (v.device_num_parent == lul_device) then
            if v.device_type == deviceType then
                lul_children.temperature_interieure
            elseif v.device_type == deviceType then
                lul_children.co2
            elseif v.device_type == deviceType then
                lul_children.humidite_interne
            elseif v.device_type == deviceType then
                lul_children.pression
            elseif v.device_type == deviceType then
                lul_children.bruit
            elseif v.device_type == deviceType then
                lul_children.temperature_externe
            elseif v.device_type == deviceType then
                lul_children.humidite_externe
            end
		end
	end
	
    -- Child not found, creat one
        local child_devices = luup.chdev.start(lul_device);

        luup.chdev.append(lul_device, child_devices, "", description , device_type, device_filename, "", "", false)
    
        -- Synch the new tree with the old three
        luup.chdev.sync(THIS_DEVICE, child_devices)

end