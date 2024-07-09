-- Polygon selection tool based on selected poly Area
-- Created by r.mehedi
-- Created on 3dsMax 2023
-- year 2024
-- free to use tool

clearListener()
-- destroyDialog SelPolyMainRollout

rollout SelPolyMainRollout "Select Small Polys V1.0" width:200 height:265
(
	label 'lbl_ShowAreaTitle' "Show area of selected poly face" align:#center width:155 height:18
	button 'btn_area_face' "Show Area" align:#left width:70 height:30 
	label 'lbl_ShowAreaTitle2' "Area :" align:#left offset:[80,-35]
	label 'lbl_ShowAreaValue' "" align:#left height:18 offset:[80,-1]
	
	label 'lbl1' "Select Poly lower than size" align:#center width:133 height:18
	editText 'sizeValue' ""  text:"0.0" width:180 height:22 align:#center tooltip:"dont press Return while typing in this textbox. It will give an error. In that case please restart the plugin"
	button 'btn_sel' "Select" width:70 height:30 align:#left
	button 'btn_selNdDelete' "Select & delete" width:90 height:30 align:#left offset:[85,-35]
	label 'lbl2' "Note:\nPlease select the objects 1st.\nMake sure the selected objects are\nEditable poly And All the faces of\nthe selected objects are triagles." align:#center height:65
	label 'lbl3' "Created by r.mehedi" width:101 height:13 align:#center offset:[0,20]
	


	-- Function to calculate the area of a triangular face
	fn getTriangleArea v1 v2 v3 =
	(
		vec1 = v2 - v1
		vec2 = v3 - v1
		crossProd = cross vec1 vec2
		area = length(crossProd) / 2.0
		return area
	)

    fn getFaceArea polyObj faceIndexNumber =
    (
        -- define verts
        local faceVerts = polyOp.getFaceVerts polyObj faceIndexNumber
        local FaceArea = 0.0

        -- calculate Area
        if faceVerts.count == 3 then
        (
            v1 = polyOp.getVert polyObj faceVerts[1]
            v2 = polyOp.getVert polyObj faceVerts[2]
            v3 = polyOp.getVert polyObj faceVerts[3]
            
            FaceArea = getTriangleArea v1 v2 v3
        )
        else if faceVerts.count == 4 then
        (
            v1 = polyOp.getVert polyObj faceVerts[1]
            v2 = polyOp.getVert polyObj faceVerts[2]
            v3 = polyOp.getVert polyObj faceVerts[3]
            v4 = polyOp.getVert polyObj faceVerts[4]
            area1 = getTriangleArea v1 v2 v3
            area2 = getTriangleArea v1 v3 v4
            
            FaceArea = area1 + area2
        )else(
            print "The Polygon instance has more then 4 vertexes or less than 3 vertexes"
        )
        return FaceArea
    )

	-- Function to calculate the area of a face and check if it's a triangle, and select if below a threshold
	fn selectSmallTriangles polyObj areaThreshold =
	(
		faceCount = polyOp.getNumFaces polyObj
		local ArrfacesToSelect = #()
        local polyArea = 0.0
		for faceIndex = 1 to faceCount do
		(
			polyArea = getFaceArea polyObj faceIndex

            format "Face Index: % - Area: %\n" faceIndex polyArea
			
			if polyArea < areaThreshold then
			(
				appendIfUnique ArrfacesToSelect faceIndex
			)
		)
		polyOp.setFaceSelection polyObj ArrfacesToSelect
		--updateShape polyObj
		format "Selected faces with area below %: %\n" areaThreshold (polyOp.getFaceSelection polyObj)
	)

	-- Show Area Button Action
	on btn_area_face pressed do
	(
        local ViewPolyArea = 0.0
		if selection.count == 1 and isKindOf (selection[1]) Editable_Poly then
        (
            selectedPolyObj = selection[1]
            selectedFace = polyOp.getFaceSelection selectedPolyObj

            if selectedFace.numberSet == 1 then
            (
				faceIndexInt = (selectedFace as array)[1]
                ViewPolyArea = getFaceArea selectedPolyObj faceIndexInt
                lbl_ShowAreaValue.text = ViewPolyArea as string
            )
            else
            (
                print "No faces are selected. Or more than 1 face ins selected"
                messageBox "Please select only one face from the Poly object."
            )
        )
        else
        (
            messageBox "Please select a single Editable Poly object."
        )
	)
	
	-- Select Button Action
	on btn_sel pressed do
	(
		local areaThreshold =  (sizeValue.text) as float
		if selection.count > 0 then
		(
			for selectedObj in selection do
			(
				if (selectedObj != undefined and isKindOf selectedObj Editable_Poly) then
				(
					undo on
					(
						selectSmallTriangles selectedObj areaThreshold
						subobjectLevel = 4
					)
					redrawViews()
				)
				else
				(
					format "The Selected object: \"% \"is not an Editable Poly object.\n" selectedObj.name
				)
			)
		)else(
			messageBox "Please select one or more Editable Poly object."
		)
	)
	
	-- Select & delete Button Action
	on btn_selNdDelete pressed do
	(
		local areaThreshold =  (sizeValue.text) as float
		if selection.count > 0 then
		(
			for selectedObj in selection do
			(
				if (selectedObj != undefined and isKindOf selectedObj Editable_Poly) then
				(
					undo on
					(selectSmallTriangles selectedObj areaThreshold)
					modPanel.addModToSelection (Edit_Poly ()) ui:on
					subobjectLevel = 4
					actionMan.executeAction 0 "40020"
					redrawViews()
				)
				else
				(
					format "The Selected object: \"% \"is not an Editable Poly object.\n" selectedObj.name
				)
			)
		)else(
			messageBox "Please select one or more Editable Poly object."
		)
	)
	
)
CreateDialog SelPolyMainRollout
cui.RegisterDialogBar SelPolyMainRollout
