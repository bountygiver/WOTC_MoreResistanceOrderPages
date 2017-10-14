class UIStrategyPolicy_LeftRightButton extends UIPanel;

var UIImage ArrowImage;
var UIBGBox MouseHitBG;



var string DefaultArrowImage;
var float TweenTime;

delegate OnButtonClicked(UIStrategyPolicy_LeftRightButton Button);

simulated function UIStrategyPolicy_LeftRightButton InitButton(delegate<OnButtonClicked> _ClickedDel)
{
	InitPanel();
	OnButtonClicked = _ClickedDel;
	MouseHitBG = Spawn(class'UIBGBox', self);
	ArrowImage = Spawn(class'UIImage', self).InitImage('', "img:///MoreResistanceOrderPagesContent.ArrowImage");
	ArrowImage.SetSize(Width, Height);
	ArrowImage.SetColor("249283");

	MouseHitBG.InitBG('mouseHit', 0, 0, Width, Height);
	MouseHitBG.SetAlpha(0.000001f);
	MouseHitBG.ProcessMouseEvents(OnMouseHitLayerCallback);

	return self;

}

simulated function OnMouseHitLayerCallback( UIPanel control, int cmd )
{
	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_DOWN:
			if (OnButtonClicked != none)
				OnButtonClicked(self);
			break;
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_IN:
			AnimateOutwards();
			break;
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
			AnimateBack();
			break;

	}
}

simulated function AnimateOutwards()
{
	ArrowImage.AddTweenBetween("_x", 0, 45, TweenTime, 0, "easeoutquad");
	ArrowImage.X = 45;
}

simulated function AnimateBack()
{
	ArrowImage.AddTweenBetween("_x", ArrowImage.X, 0, TweenTime, 0, "easeoutquad");
	ArrowImage.X = 0;
}

// Override because we can't trigger mouse events while hidden
simulated function Hide()
{
	if( bIsVisible )
	{
		bIsVisible = false;
		if (MC != none)
		{	
			MC.FunctionVoid("Hide");
			AnimateBack();
		}
	}
}

// image is actually 128x438
defaultproperties
{
	Width=128
	Height=438
	TweenTime=0.4f
}
