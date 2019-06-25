local utilities = require("Utilities")
local this = UIComponent(Address)
local monarch_setting = UIComponent(this:Find("faction_leader"))
local spouse_setting = UIComponent(this:Find("faction_leaders_spouse"))
local heirs_settings = {
  UIComponent(this:Find("child1")),
  UIComponent(this:Find("child2")),
  UIComponent(this:Find("child3")),
  UIComponent(this:Find("child4"))
}
local claimants_settings = {
  UIComponent(this:Find("claimant1")),
  UIComponent(this:Find("claimant2")),
  UIComponent(this:Find("claimant3")),
  UIComponent(this:Find("claimant4"))
}
local monarch_line = UIComponent(this:Find("monarch_line"))
local spouse_line = UIComponent(this:Find("spouse_line"))
local localised_married_string = CampaignUI.LocalisationString("Married")
local localised_single_string = CampaignUI.LocalisationString("Single")
local localised_children_string = CampaignUI.LocalisationString("Children")
local card_components = {}
function ReInitialise()
  card_components = {}
  for i = 1, #heirs_settings do
    if 1 < heirs_settings[i]:ChildCount() then
      assert(heirs_settings[i]:Find(1) ~= nil)
      Component.Destroy(heirs_settings[i]:Find(1))
    end
  end
  for i = 1, #claimants_settings do
    claimants_settings[i]:DestroyChildren()
  end
end
function Initialise(info)
  local close_button = UIComponent(this:Find("button_close"))
  close_button:SetProperty("ParentPopup", Address)
  card_components[#card_components + 1] = SetupCard(monarch_setting, "monarch", info.monarch, false)
  if info.spouse ~= nil then
    card_components[#card_components + 1] = SetupCard(spouse_setting, "spouse", info.spouse, false)
  else
    local p_x, p_y = this:Position()
    local x, y = monarch_setting:Position()
    monarch_setting:MoveTo(p_x + 279, y)
  end
  spouse_line:SetVisible(info.spouse ~= nil)
  monarch_line:SetVisible(#info.heirs > 0)
  for i = 1, #info.heirs do
    card_components[#card_components + 1] = SetupCard(heirs_settings[i], "heir" .. i, info.heirs[i], true)
  end
  for i = 1, #info.claimants do
    card_components[#card_components + 1] = SetupCard(claimants_settings[i], "claimants" .. i, info.claimants[i], true)
  end
end
function SetupCard(location, id, card_data, selectable)
  location:PropagateVisibility(true)
  local images = {
    "{" .. id .. ":1}" .. card_data.portrait_path,
    "{faction_key:1}" .. card_data.flag_path
  }
  local card = UIComponent(Component.CreateComponentFromTemplate("FamilyTreeCard", id, location:Address(), 0, 0, images))
  card:SetInteractive(selectable)
  if card_data.chosen == true then
    UIComponent(card:Find("crown")):SetVisible(true)
    card:SetState("Selected")
  else
    UIComponent(card:Find("crown")):SetVisible(false)
    card:SetState("Default")
  end
  UIComponent(card:Find("dy_title")):SetStateText(card_data.title)
  UIComponent(card:Find("dy_name")):SetStateText(card_data.name)
  if card_data.religion_differs == true then
    UIComponent(card:Find("religion")):SetVisible(true)
  else
    UIComponent(card:Find("religion")):SetVisible(false)
  end
  if 0 < card_data.management_level then
    UIComponent(card:Find("CharacterAttribute")):SetVisible(true)
    UIComponent(card:Find("Level")):SetState(card_data.management_level)
  else
    UIComponent(card:Find("CharacterAttribute")):SetVisible(false)
  end
  local tooltip = card_data.title .. ", " .. card_data.name .. "\n" .. "Age: " .. card_data.age .. [[

Status: ]]
  if card_data.married == true then
    tooltip = tooltip .. localised_married_string .. "\n"
  else
    tooltip = tooltip .. localised_single_string .. "\n"
  end
  tooltip = tooltip .. localised_children_string .. " " .. card_data.children .. "\n"
  card:SetTooltipText(tooltip)
  return card
end
function SelectHeir(card)
  out.shane("Reached select heir")
  CampaignUI.SetSuccessor(card:Id())
  for i = 1, #card_components do
    if card_components[i]:Address() ~= card then
      card_components[i]:SetState("Default")
      UIComponent(card_components[i]:Find("crown")):SetVisible(false)
    else
      card_components[i]:SetState("Selected")
      UIComponent(card_components[i]:Find("crown")):SetVisible(true)
    end
  end
end
