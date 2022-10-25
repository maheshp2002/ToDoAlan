import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum AniProps { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation({required this.delay, required  this.child});

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)
      ..add(AniProps.translateY, (-30.0).tweenTo(0.0), 500.milliseconds,
          Curves.easeOut);


    return PlayAnimation<MultiTweenValues<AniProps>>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(0, value.get(AniProps.translateY)), child: child),
      ),
    );
  }
}

//left animation
enum AniPropsHorizontal { opacity, translateX }

class FadeAnimationHorizontal extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimationHorizontal({required this.delay, required  this.child});

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniPropsHorizontal>()
      ..add(AniPropsHorizontal.translateX, (-30.0).tweenTo(0.0), 500.milliseconds,
          Curves.easeOut)
      ..add(AniPropsHorizontal.opacity, 0.0.tweenTo(1.0), 500.milliseconds);


    return PlayAnimation<MultiTweenValues<AniPropsHorizontal>>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get(AniPropsHorizontal.opacity),
        child: Transform.translate(
            offset: Offset(0, value.get(AniPropsHorizontal.translateX)), child: child),
      ),
    );
  }
}