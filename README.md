# 开头

这次和之前不一样，我们直接来看最终的动画实现效果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/002.gif)



![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/001.gif)

（使用琦玉老师作为例子，是因为他的画风比较简单，非常适合新手操作！！！）

动画演示完毕，接下来，就是实现过程啦。

听，是引擎的声音..

# 动画部分

如果你对于Flare的一些基础使用尚不熟悉，可以先去了解一下这篇文章：
[打开Flutter动画的另一种姿势——Flare](https://juejin.im/post/5d1ac9e051882579cc3cb88f)


## 绘制图形

首先，我们需要将一拳超人画出来，可以先在绘图软件上生成svg，再导入flare的项目中；或者也可以直接在flare项目中进行绘制。

这里为了方便起见，我是通过前者的方式去实现的

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/003.png)

将琦玉老师创造成功后，我就可以准备下一步操作了

[【琦玉老师.svg】](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/one_punch.svg)

## 添加约束

上面的动画里面，我们可以看到琦玉的脸部是随着手指移动的，所以我们需要将一起跟随移动的部位添加同一个约束

创建一个Node节点，将其display属性换成target

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/004.gif)

然后我们开始将多个脸部内容与这个节点约束在一起，下面以左眼眶为例：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/005.gif)


其中我们有对每个约束的 **Strength** 进行调整，参数为1时，被约束的控件位置会和节点位置保持一致，所以这里会根据控件与节点的距离来设置不同的大小

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/006.png)

当我们所有约束都设置完成后，就可以看到如下效果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/007.gif)

同时，我们这里将节点名字设置为了 **ctrl_eyes** 

之后我们再创建三个非常简单的动画，动画名为idel、fail、success，其中，fail和success的效果如下：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/008.gif)

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/one_punch/009.gif)

接下来，我们开始准备用代码去控制这个动画！


# 代码部分

使用代码去控制动画才是这篇文章的重中之重，在此之前，先确保项目中已经添加了flare的依赖

```
  flare_flutter: ^1.5.2
```

上一篇文章中，我们只是使用了flare提供的最基本的功能，现在要真正实现动画与代码的交互，就不得不介绍一下 **FlareController** 

## FlareController

一般情况下，我们要通过继承的方式去使用 **FlareController** ，因为它是一个抽象类，这个类中有三个需要重写的方法：

- <code>**initialize(FlutterActorArtboard artboard)**</code> ：这个方法会在动画初始时调用，在整个FlareController的生命周期中，只会调用一次。其中的 **artboard** 参数表示画板对象，可以通过它获取到所有节点，以及所有的动画
- <code>**setViewTransform(Mat2D viewTransform)**</code>： 这个方法用于进行矩阵坐标的传递，其中的 **viewTransform** 参数表示flare画板中的2d矩阵坐标
- <code>**advance(FlutterActorArtboard artboard, double elapsed)**</code> ：这个方法会在每一帧都调用一次，操作动画的主要逻辑就在这里。其中 **elapsed** 参数表示消耗的时间


官方给我们提供了一个 <code>FlareControls</code> 类，这个类封装好了一些基础的方法，所以我们实现的Controller继承这个类即可

接下来，我们来实现自定义的Controller，编写一个 **MyController** 继承 **FlareControls**

看一下其中的部分方法：

```
class MyController extends FlareControls{
    //用于获取ctrl_eyes节点
    ActorNode _eyeControl;
    
    // 存储"约束脸部节点"坐标
    Vec2D _eyeOrigin = Vec2D();
    Vec2D _eyeOriginLocal = Vec2D();
    ...
    
    @override
    void initialize(FlutterActorArtboard artboard) {
        super.initialize(artboard);
        _eyeControl = artboard.getNode("ctrl_eyes");
        if (_eyeControl != null) {
            _eyeControl.getWorldTranslation(_eyeOrigin);
            Vec2D.copy(_eyeOriginLocal, _eyeControl.translation);
        }
        play("idle");
    }
    ...
    
}
```
在 **initialize** 中获取到了之前拖拽的脸部约束节点，并且进行了存储。


```
  // 用于存储从flare转换到flutter的矩阵
  Mat2D _globalToFlareWorld = Mat2D();


  @override
  void setViewTransform(Mat2D viewTransform) {
    super.setViewTransform(viewTransform);
    Mat2D.invert(_globalToFlareWorld, viewTransform);
  }

```

**setViewTransform** 方法中进行了矩阵坐标的倒置。

其实关于矩阵坐标的相关逻辑都是比较晦涩抽象的，这里只要照搬即可，下面的 **advance** 方法同样如此


```

  // 在flutter中当前焦点所在的坐标
  Vec2D _caretGlobal = Vec2D();

  // 在flare中当前焦点所在的坐标
  Vec2D _caretWorld = Vec2D();

  //判断是否正在输入
  bool _hasFocus = false;

  String _password = "";


  MyController({this.projectGaze = 100});
  
  //这个参数用于缩放从输入焦点到约束节点之间的距离
  final double projectGaze;
  
  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);
    Vec2D targetTranslation;

    if(_hasFocus){
      // 获取到flare中当前焦点所在的坐标
      Vec2D.transformMat2D(_caretWorld, _caretGlobal, _globalToFlareWorld);

      //这里是实现了动画的"呼吸"效果，是为了避免动画静止不动，让动画更加有趣
      _caretWorld[1] += sin(new DateTime.now().millisecondsSinceEpoch / 300.0) * 70.0;

      // 计算矢量方向
      Vec2D toCaret = Vec2D.subtract(Vec2D(), _caretWorld, _eyeOrigin);

      //获取比例，再进行缩放
      Vec2D.normalize(toCaret, toCaret);
      Vec2D.scale(toCaret, toCaret, projectGaze);

      //用于计算"约束节点"到输入焦点到距离
      Mat2D toFaceTransform = Mat2D();
      if (Mat2D.invert(toFaceTransform, _eyeControl.parent.worldTransform)) {
        Vec2D.transformMat2(toCaret, toCaret, toFaceTransform);
        targetTranslation = Vec2D.add(Vec2D(), toCaret, _eyeOriginLocal);
      }
    } else {
      targetTranslation = Vec2D.clone(_eyeOriginLocal);
    }

    Vec2D diff =
    Vec2D.subtract(Vec2D(), targetTranslation, _eyeControl.translation);
    Vec2D frameTranslation = Vec2D.add(Vec2D(), _eyeControl.translation,
        Vec2D.scale(diff, diff, min(1.0, elapsed * 5.0)));


    _eyeControl.translation = frameTranslation;

    return true;
  }
```
**advance** 方法返回 **true** 表示每帧都进行刷新

实现完MyController之后，再搭配官方提供的 **tracking_text_input.dart** 与 **input_helper.dart** 就可以实现 琦玉眼睛跟随输入框的效果了

# 附录

## 参考文章

[Building an Interactive Login Screen with Flare & Flutter](https://medium.com/2dimensions/building-an-interactive-login-screen-with-flare-flutter-749db628bb51)

## 环形列表控件

[【circle_list】](https://pub.flutter-io.cn/packages/circle_list)

环形列表是我写的一个dart插件



