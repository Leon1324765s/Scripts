do local Players=game:GetService("Players");local UserInputService=game:GetService("UserInputService");local StarterGui=game:GetService("StarterGui");local HttpService=game:GetService("HttpService");local MarketplaceService=game:GetService("MarketplaceService");local player=Players.LocalPlayer;local playerGui=player:WaitForChild("PlayerGui");local KEYBINDS_FOLDER="KeybindMakerConfigs";pcall(function() makefolder(KEYBINDS_FOLDER);end);local placeId=game.PlaceId;local universeId=game.GameId;local function getConfigFileName(isUniversal) if isUniversal then return KEYBINDS_FOLDER   .. "/KeybindsConfigUniversal.txt" ;else return KEYBINDS_FOLDER   .. "/KeybindsConfig_"   .. placeId   .. ".txt" ;end end local function getAllConfigsInUniverse() local configs={};local success,files=pcall(function() return listfiles(KEYBINDS_FOLDER);end);if success then for _,file in ipairs(files) do if string.match(file,"KeybindsConfig_") then configs[ #configs + 1 ]=file;end end end return configs;end local function getPlaceIdFromConfig(filename) local placeIdStr=string.match(filename,"KeybindsConfig_(%d+).txt$");return placeIdStr and tonumber(placeIdStr) ;end local function isSubplace(parentId,childId) local success,parentInfo=pcall(function() return MarketplaceService:GetProductInfo(parentId);end);if (success and parentInfo.Creator.Id) then local success,childInfo=pcall(function() return MarketplaceService:GetProductInfo(childId);end);return success and (childInfo.Creator.Id==parentInfo.Creator.Id) ;end return false;end local function loadKeybindsFromFile(fileName) local success,data=pcall(function() return readfile(fileName);end);if (success and data) then local success,decodedData=pcall(function() return HttpService:JSONDecode(data);end);if (success and decodedData) then return decodedData;end end return nil;end local keybinds={};local guiToggleKey=Enum.KeyCode.F4;local screenGui=Instance.new("ScreenGui",playerGui);screenGui.Name="KeybindMaker";local mainFrame=Instance.new("Frame",screenGui);mainFrame.Size=UDim2.new(0,400,0,550);mainFrame.Position=UDim2.new(0.5, -200,0.5, -275);mainFrame.BackgroundColor3=Color3.fromRGB(45,45,45);mainFrame.BorderSizePixel=0;mainFrame.Active=true;mainFrame.Draggable=true;local uiCorner=Instance.new("UICorner",mainFrame);uiCorner.CornerRadius=UDim.new(0,10);local titleLabel=Instance.new("TextLabel",mainFrame);titleLabel.Size=UDim2.new(1,0,0,50);titleLabel.Text="Keybind Maker";titleLabel.TextSize=24;titleLabel.Font=Enum.Font.SourceSansBold;titleLabel.TextColor3=Color3.fromRGB(255,255,255);titleLabel.BackgroundTransparency=1;titleLabel.Position=UDim2.new(0,0,0,0);local loadButton=Instance.new("TextButton",mainFrame);loadButton.Size=UDim2.new(0,80,0,30);loadButton.Position=UDim2.new(1, -90,0,10);loadButton.Text="Load";loadButton.Font=Enum.Font.SourceSansBold;loadButton.TextSize=14;loadButton.TextColor3=Color3.fromRGB(255,255,255);loadButton.BackgroundColor3=Color3.fromRGB(30,30,30);local toggleKeyLabel=Instance.new("TextButton",mainFrame);toggleKeyLabel.Size=UDim2.new(0,80,0,30);toggleKeyLabel.Position=UDim2.new(0,10,0,10);toggleKeyLabel.Text=guiToggleKey.Name;toggleKeyLabel.Font=Enum.Font.SourceSansBold;toggleKeyLabel.TextSize=14;toggleKeyLabel.TextColor3=Color3.fromRGB(255,255,255);toggleKeyLabel.BackgroundColor3=Color3.fromRGB(30,30,30);local scriptTextBox=Instance.new("TextBox",mainFrame);scriptTextBox.Size=UDim2.new(1, -20,0,150);scriptTextBox.Position=UDim2.new(0,10,0,50);scriptTextBox.PlaceholderText="Paste your script here...";scriptTextBox.Text="";scriptTextBox.Font=Enum.Font.SourceSans;scriptTextBox.TextSize=16;scriptTextBox.TextColor3=Color3.fromRGB(255,255,255);scriptTextBox.BackgroundColor3=Color3.fromRGB(40,40,40);local dropdown=Instance.new("TextButton",mainFrame);dropdown.Size=UDim2.new(1, -20,0,40);dropdown.Position=UDim2.new(0,10,0,210);dropdown.Text="Select Key";dropdown.Font=Enum.Font.SourceSansBold;dropdown.TextSize=16;dropdown.TextColor3=Color3.fromRGB(255,255,255);dropdown.BackgroundColor3=Color3.fromRGB(30,30,30);local nameTextBox=Instance.new("TextBox",mainFrame);nameTextBox.Size=UDim2.new(1, -20,0,40);nameTextBox.Position=UDim2.new(0,10,0,255);nameTextBox.PlaceholderText="Enter keybind name";nameTextBox.Text="";nameTextBox.Font=Enum.Font.SourceSans;nameTextBox.TextSize=16;nameTextBox.TextColor3=Color3.fromRGB(255,255,255);nameTextBox.BackgroundColor3=Color3.fromRGB(40,40,40);local addButton=Instance.new("TextButton",mainFrame);addButton.Size=UDim2.new(1, -20,0,40);addButton.Position=UDim2.new(0,10,0,305);addButton.Text="Add Keybind";addButton.Font=Enum.Font.SourceSansBold;addButton.TextSize=16;addButton.TextColor3=Color3.fromRGB(255,255,255);addButton.BackgroundColor3=Color3.fromRGB(50,150,50);local modeToggle=Instance.new("TextButton",mainFrame);modeToggle.Size=UDim2.new(1, -20,0,30);modeToggle.Position=UDim2.new(0,10,0,350);modeToggle.Text="Place Specific";modeToggle.Font=Enum.Font.SourceSansBold;modeToggle.TextSize=14;modeToggle.TextColor3=Color3.fromRGB(255,255,255);modeToggle.BackgroundColor3=Color3.fromRGB(30,30,30);local isUniversalMode=false;local configFileName=getConfigFileName(isUniversalMode);local managerFrame=Instance.new("ScrollingFrame",mainFrame);managerFrame.Size=UDim2.new(1, -20,0,150);managerFrame.Position=UDim2.new(0,10,0,385);managerFrame.BackgroundColor3=Color3.fromRGB(35,35,35);managerFrame.ScrollBarThickness=8;managerFrame.CanvasSize=UDim2.new(0,0,1,0);local uiListLayout=Instance.new("UIListLayout",managerFrame);uiListLayout.Padding=UDim.new(0,5);uiListLayout.FillDirection=Enum.FillDirection.Vertical;uiListLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;local addKeybind;local saveKeybinds;local loadKeybinds;function saveKeybinds() local saveData={};for key,bind in pairs(keybinds) do if (typeof(key)=="EnumItem") then saveData[key.Name]={Script=bind.Script,Name=bind.Name,Enabled=bind.Enabled};end end local success,data=pcall(function() return HttpService:JSONEncode(saveData);end);if success then print("Encoded data:",data);configFileName=getConfigFileName(isUniversalMode);local success,err=pcall(function() writefile(configFileName,data);end);if success then print("Keybinds Saved Successfully to "   .. configFileName );else print("Error saving keybinds:",err);end else print("Error encoding keybinds:",data);end end function addKeybind(key,script,name,skipCheck,bind) if ( not skipCheck and keybinds[key]) then StarterGui:SetCore("SendNotification",{Title="Keybind Exists",Text="Key already assigned!",Duration=3});return;end if (key and script) then keybinds[key]={Enabled=true,Script=script,Name=name or key.Name };local keybindFrame=Instance.new("Frame",managerFrame);keybindFrame.Size=UDim2.new(0.9,0,0,30);keybindFrame.BackgroundColor3=Color3.fromRGB(50,150,50);local keybindLabel=Instance.new("TextLabel",keybindFrame);keybindLabel.Size=UDim2.new(0.7,0,1,0);keybindLabel.Text="Key: "   .. key.Name   .. " ("   .. (name or "No Name")   .. ")" ;keybindLabel.TextSize=14;keybindLabel.Font=Enum.Font.SourceSans;keybindLabel.TextColor3=Color3.fromRGB(255,255,255);keybindLabel.BackgroundTransparency=1;local toggleButton=Instance.new("TextButton",keybindFrame);toggleButton.Size=UDim2.new(0.15,0,1,0);toggleButton.Position=UDim2.new(0.7,0,0,0);toggleButton.Text="Disable";toggleButton.TextSize=12;toggleButton.Font=Enum.Font.SourceSans;toggleButton.TextColor3=Color3.fromRGB(255,255,255);toggleButton.BackgroundColor3=Color3.fromRGB(150,50,50);local removeButton=Instance.new("TextButton",keybindFrame);removeButton.Size=UDim2.new(0.15,0,1,0);removeButton.Position=UDim2.new(0.85,0,0,0);removeButton.Text="Remove";removeButton.TextSize=12;removeButton.Font=Enum.Font.SourceSans;removeButton.TextColor3=Color3.fromRGB(255,255,255);removeButton.BackgroundColor3=Color3.fromRGB(150,50,50);toggleButton.MouseButton1Click:Connect(function() keybinds[key].Enabled= not keybinds[key].Enabled;toggleButton.Text=(keybinds[key].Enabled and "Disable") or "Enable" ;keybindFrame.BackgroundColor3=(keybinds[key].Enabled and Color3.fromRGB(50,150,50)) or Color3.fromRGB(150,50,50) ;saveKeybinds();end);removeButton.MouseButton1Click:Connect(function() keybinds[key]=nil;keybindFrame:Destroy();saveKeybinds();end);if (skipCheck and bind and (bind.Enabled~=nil)) then keybinds[key].Enabled=bind.Enabled;toggleButton.Text=(bind.Enabled and "Disable") or "Enable" ;keybindFrame.BackgroundColor3=(bind.Enabled and Color3.fromRGB(50,150,50)) or Color3.fromRGB(150,50,50) ;end if  not skipCheck then saveKeybinds();end else print("Error: Invalid key or script.");end end function loadKeybinds() for _,child in pairs(managerFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy();end end keybinds={};local loadedKeybinds=nil;if isUniversalMode then local universalConfig=getConfigFileName(true);loadedKeybinds=loadKeybindsFromFile(universalConfig);else local placeConfig=getConfigFileName(false);loadedKeybinds=loadKeybindsFromFile(placeConfig);if  not loadedKeybinds then local configs=getAllConfigsInUniverse();for _,config in ipairs(configs) do local configPlaceId=getPlaceIdFromConfig(config);if (configPlaceId and (configPlaceId~=placeId) and isSubplace(configPlaceId,placeId)) then print("Found parent place config:",config);loadedKeybinds=loadKeybindsFromFile(config);if loadedKeybinds then break;end end end end end if loadedKeybinds then local bindData=loadedKeybinds.keybinds or loadedKeybinds ;for keyName,bind in pairs(bindData) do print("Processing key:",keyName);local keyCode=Enum.KeyCode[keyName];if keyCode then print("Adding keybind for:",keyName,"Enabled:",bind.Enabled);addKeybind(keyCode,bind.Script,bind.Name,true,bind);else print("Invalid key name:",keyName);end end else print("No keybind config found");end end loadButton.MouseButton1Click:Connect(function() loadKeybinds();StarterGui:SetCore("SendNotification",{Title="Keybinds Loaded",Text="Keybinds have been loaded successfully!",Duration=3});end);toggleKeyLabel.MouseButton1Click:Connect(function() toggleKeyLabel.Text="Press a Key...";local input=UserInputService.InputBegan:Wait();if ((input.UserInputType==Enum.UserInputType.Keyboard) and (input.KeyCode~=Enum.KeyCode.Unknown)) then guiToggleKey=input.KeyCode;toggleKeyLabel.Text=guiToggleKey.Name;saveKeybinds();end end);dropdown.MouseButton1Click:Connect(function() dropdown.Text="Press a Key...";local input=UserInputService.InputBegan:Wait();if (input.KeyCode~=Enum.KeyCode.Unknown) then dropdown.Text=input.KeyCode.Name;else dropdown.Text="Select Key";end end);addButton.MouseButton1Click:Connect(function() local script=scriptTextBox.Text;local keyName=dropdown.Text;local name=nameTextBox.Text;if ((script=="") or (keyName=="Select Key") or (keyName=="Press a Key...")) then StarterGui:SetCore("SendNotification",{Title="Error",Text="Please select a key and enter a script!",Duration=3});return;end local key=Enum.KeyCode[keyName];if key then addKeybind(key,script,name);else print("Invalid key selected:",keyName);end scriptTextBox.Text="";nameTextBox.Text="";dropdown.Text="Select Key";end);modeToggle.MouseButton1Click:Connect(function() isUniversalMode= not isUniversalMode;modeToggle.Text=(isUniversalMode and "Universal") or "Place Specific" ;configFileName=getConfigFileName(isUniversalMode);loadKeybinds();StarterGui:SetCore("SendNotification",{Title="Keybinds Loaded",Text=(isUniversalMode and "Switched to Universal Mode") or "Switched to Place Specific Mode" ,Duration=3});end);UserInputService.InputBegan:Connect(function(input,gameProcessed) if gameProcessed then return;end if (input.UserInputType==Enum.UserInputType.Keyboard) then if (input.KeyCode==guiToggleKey) then screenGui.Enabled= not screenGui.Enabled;else local key=input.KeyCode;if (keybinds[key] and keybinds[key].Enabled) then local success,err=pcall(function() loadstring(keybinds[key].Script)();end);if  not success then warn("Error executing keybind script:",err);end end end end end);loadKeybinds(); end