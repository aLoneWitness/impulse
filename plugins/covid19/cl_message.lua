local cookieName = "impulse_covid19_warn"
local message = "COVID-19 is a new illness that can affect your lungs and airways. It is easily spread. Ensure you wash your hands and follow the advice of your local health service."

if cookie.GetNumber(cookieName, 0) < os.time() then
	impulse.MenuMessage.Remove("covid19warning")
	impulse.MenuMessage.Add("covid19warning", "COVID-19 (Coronavirus) Alert", message, nil, "https://www.nhs.uk/coronavirus", "More information (nhs.uk)")
	impulse.MenuMessage.Save()
	
	cookie.Set(cookieName, os.time() + 172800)
end