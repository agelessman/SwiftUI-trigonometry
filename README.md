# SwiftUI-trigonometry
swiftUI三角函数的演示
随着本人对SwiftUI了解地越来越深入，我发现SwiftUI并不像表面上看上去的那么简单，在初学的时候，我们看到的东西往往是浮在水面上最直观的表象，随着我们的下潜，我们就看到了那些有趣深奥，充满魅力的东西。也许，之前我们认为用SwiftUI比较难实现的功能，此时此刻，却变得十分easy。

对于frame来说，很多人觉得它实在是太简单了，做过iOS开发的都知道frame是怎么一回事，bounds是怎么一回事，但在SwiftUI中，它几乎完全不同于我们平时用过的frame。SwiftUI本质上运行在一套新的规则之上，对于SwiftUI来说，frame当然也有它自己的规则。

在原作者的文章中，他并没有讲解SwiftUI中布局的基本原则， 对于部分读者来说，理解原文可能会有一点困难，在本篇文章中，我会用一部分的篇幅，来讲解SwiftUI中布局的基本原则，结合这些原则，再回头去看frame，一定会发出这样一句惊叹：“原来如此！！！”

## frame是什么

在SwiftUI中，`frame()`是一个modifier，**modifier在SwiftUI中并不是真的修改了view。**大多数情况下，当我们对某个view应用一个modifier的时候，实际上会创建一个新的view。

在SwiftUI中，views并没有frame的概念，但是它们有bounds的概念，也就是说每个view都有一个范围和大小，它们的bounds不能够直接通过手动的方式去修改。

当某个view的frame改变后，其child的size不一定会变化，比如，我们修改一个容器`VStack`的宽度后，其内部child的布局有可能变化，也有可能不变化。我们会在下边验证这个说法。

大家记住这句话，**每个view对自己需要的size，都有自己的想法**，这是我们下边内容讲解的核心思想。

## Behaviors

在SwfitUI中，view在计算自己size的时候会有不同的行为方式，我们分为4类：

- 类似于`Vstack`，它们会尽可能让自己内部的内容展示完整，但也不会多要其他的额外空间
- 类似于`Text`这种只返回自身需要的size，如果size不够，它非常聪明的做一些额外的操作，比如换行等等
- 类似于`Shape`这种给多大尺寸就使用多大尺寸
- 还有一些可能超出父控件的view

还存在其他一些比较特殊的例外，比如`Spacer`,他的特性跟他属于哪个容器或者哪个轴有关系。当他在`VStack`中时，他会尽可能的占据剩余垂直的全部空间，而占据的水平空间为0，在`HStack`中，他的行为却又恰恰相反。

我们在下一小节的布局原则中，就会看到这些不同行为的表现了。

## 布局原则

大家仔细思考我接下来的这3句话：

- 当布局某个view时，其父view会给出一个建议的size
- 如果该view存在child，那么就拿着这个建议的尺寸去问他的child，child根据自身的behavior返回一个size，如果没有child，则根据自身的behavior返回一个size
- 用该size在其父view中进行布局

我们看一个简单的例子：

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

布局的过程是自下而上的，我们计算ContentView的size

- ContentView的父view为其提供了一个size等于全屏幕的建议尺寸
- ContentVIew拿着该尺寸去问其child，Text返回了一个自身需要的size
- 用该size在父view中布局

基于这3个基本原则，我们分析出，ContentView的size其实是跟Text一样的：

![1](https://i.loli.net/2020/06/13/OeWT9dPIA3mJwkl.png)

我们在此基础上再增加一点难度：

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .frame(width: 200, height: 100)
            .background(Color.green)
            .frame(width: 400, height: 200)
            .background(Color.orange.opacity(0.5))
    }
}
```

上边这段代码基本上能够代表任何一个自定义view的情况了，不要忘记，在考虑布局的时候，是自下而上的。

我们先考虑ContentVIew，他的父view给他的建议尺寸为整个屏幕的大小，我们称为size0，他去询问他的child，他的child为最下边的那个background，这个background自己也不知道自己的size，因此他继续拿着size0去询问他自己的child，他的child是个frame，返回了width400， height200， 因此background告诉ContentView他需要的size为width400， height200，因此最终ContentView的size为width400， height200。

很显然，我们也计算出了最下边background的size，注意，里边的Color也是一个view，Color本身是一个Shape，background返回一个透明的view

我们再考虑最上边的background，他父view给的建议的size为width: 400, height: 200，他询问其child，得到了需要的size为width: 200, height: 100，因此该background的size为width: 200, height: 100。

我们在看Text，父View给的建议的size为width: 200, height: 100，但其只需要正好容纳文本的size，因此他的size并不会是width: 200, height: 100

我们看下布局的效果：

![2](https://i.loli.net/2020/06/10/SuOte7cVsm1Ua6P.png)

这里大家必须要理解Text的size并不会是width: 200, height: 100，这跟我们平时开发的思维有所不同。

了解了这些布局的知识后，我们再往下看文章，就不会有那么的疑惑，在平时的开发中，对于出现比较奇怪的布局问题，也能知道造成这些问题的原因是什么了。

## 基本用法

我们在开发中，使用frame最频繁的方法是：

```swift
func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center)
```

我们之前写了一篇专门讲解alignment的文章；[[SwiftUI之AlignmentGuides](https://zhuanlan.zhihu.com/p/145821031)](https://zhuanlan.zhihu.com/p/145821031),没有看过的同学一定要去看一下， 在SwiftUI中，理解Alignment Guides的用法，能够让我们开发效果更加高效。

当我们修改了width或者height的时候，大多数情况下布局的效果跟我们想象中的一样，表面上看，我们通过这个方法能够设置width和height，实际上frame本质上并不能直接修改view的size。

我们在上一小节，演示了布局的3个步骤，frame恰恰能够改变父或者子的size值，当view询问child的时候，如果遇到frame，则直接使用该size作为child返回的size。

接下来我们演示一个小demo， 当我们修改父view的宽度的时候，子view不一定完全随着父view的宽度改变而改变。大家将会看到，布局的3个步骤再次验证了这些变化。

```swift
struct ExampleView: View {
    @State private var width: CGFloat = 50
    
    var body: some View {
        VStack {
            SubView()
                .frame(width: self.width, height: 120)
                .border(Color.blue, width: 2)
            
            Text("Offered Width \(Int(width))")
            Slider(value: $width, in: 0...200, step: 1)
        }
    }
}


struct SubView: View {
    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(Color.yellow.opacity(0.7))
                .frame(width: max(proxy.size.width, 120), height: max(proxy.size.height, 120))
        }
    }
}
```

![3](https://i.loli.net/2020/06/12/1xVCbFj2XRtrPlW.gif)

可以看出，黄色方块的宽度依赖`frame(width: max(proxy.size.width, 120), height: max(proxy.size.height, 120))`，他在计算size的时候，会使用该frame限定的size，因此，上边显示的效果正好符合我们的预期。

## 其他用法

出了上边的基本用法外，还有下边这样的用法：

```swift
func frame(minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center)
```

很明显，这么多参数可以分为3组：

- minWidth，idealWidth，maxWidth
- minHeight，idealHeight，maxHeight
- alignment

最后一组我们在其他文章中已经讲的很明白了，第一组和第二组在原理上基本相同，我们重点拿出第一组来做一个详细的讲解。

当我们给minWidth，idealWidth，maxWidth赋值的时候，一定要遵循数值递增原则，否则，xcode会给出错误提示。

minWidth表示的是最小的宽度， idealWidth表示最合适的宽度，maxWidth表示最大的宽度，**通常如果我们用到了该方法，我们只需要考虑minWidth和maxWidth就行了。**

在计算size的时候，他们遵循下边这个流程：

![4](https://i.loli.net/2020/06/13/rQc5pnNuhlokBga.png)

其实，如果大家理解了布局的3个原则，那么理解这个流程就很简单了，frame modifier通过计算minWidth，maxWidth和child size ，就可以看着上边的规则返回一个size，view用这个size作为自身在父view中的size。

我们简单看几个例子：

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .frame(minWidth: 40, maxWidth: 400)
            .background(Color.orange.opacity(0.5))
            .font(.largeTitle)
    }
}
```

上边的代码中，我们同时设置了minWidth和maxWidth，background的size返回400：

![5](https://i.loli.net/2020/06/13/mKIkSoGdN9tWwXO.png)

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .frame(minWidth: 400)
            .background(Color.orange.opacity(0.5))
            .font(.largeTitle)
    }
}
```

如果只设置了minWidth，那么background的size返回400：

![6](https://i.loli.net/2020/06/13/mKIkSoGdN9tWwXO.png)

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: 400)
            .background(Color.orange.opacity(0.5))
            .font(.largeTitle)
    }
}

```

只要设置了maxWidth，background返回的就是maxWidth的值。 

关于这里流程的各种各样的情况，大家只需要自己写一点代码实验一下就行了，总之，按照前边说的布局3大原则来理解布局就行了。

## Fixed Size Views

我们一定见过 .fixedSize()`这个modifier，表面上看，他好像应该是用在Text上的，用来固定Text的宽度，相信很多同学应该是这个想法，在这一小节，我们就会彻底理解它究竟是怎样一个东西。

```swift
func fixedSize() -> some View
func fixedSize(horizontal: Bool, vertical: Bool) -> some View
```

在SwiftUI中，任何View都可以用这个modifer，当我们应用了该modifier后，布局系统在返回size的时候，就会返回与之对应的idealWIdth或者idealHeight。

我们先看一段代码：

```swift
struct ContentView: View {
    var body: some View {
        Text("这个文本还挺长的，到达了一定字数后，就超过了一行的显示范围了！！！")
            .border(Color.blue)
            .frame(width: 200, height: 100)
            .border(Color.green)
            .font(.title)
    }
}
```

![7](https://i.loli.net/2020/06/13/158BYNHKyOiJefg.png)

按照3大布局原则，绿色边框的宽为200， 高为100， 蓝色边框的父view提供的宽为200， 高为100，其child， text在宽为200， 高为100限制下，返回了篮框的size，因此篮框和text的size相同。这个结果符合我们分析的结果。

我们修改一下代码：

```swift
struct ContentView: View {
    var body: some View {
        Text("这个文本还挺长的，到达了一定字数后，就超过了一行的显示范围了！！！")
            .fixedSize(horizontal: true, vertical: false)
            .border(Color.blue)
            .frame(width: 200, height: 100)
            .border(Color.green)
            .font(.title)
    }
}
```

![8](https://i.loli.net/2020/06/13/r7lo9dXSet5Pk3v.png)

可以看到，绿框没有任何变化，篮框变宽了，当在水平方向上应用了fixedSize时，`.border(Color.blue)`在询问child的size时，child会返回它的idealWidth，我们并没有给出一个指定的idealWidth，每个view里边都有自己的idealWidth。

那么我们验证下，我们给它显式的指定一个idealWidth：

```swift
struct ContentView: View {
    var body: some View {
        Text("这个文本还挺长的，到达了一定字数后，就超过了一行的显示范围了！！！")
            .frame(idealWidth: 300)
            .fixedSize(horizontal: true, vertical: false)
            .border(Color.blue)
            .frame(width: 200, height: 100)
            .border(Color.green)
            .font(.title)
    }
}
```

![9](https://i.loli.net/2020/06/13/XNiPu4b1e6MdHpU.png)

可以看出来，完全符合我们预想的结果，因此，当我们想要固定某个view的某个轴的尺寸的时候，fixedSize这个modifier是一个利器。

## 应用

原作者写了一个演示fixedSize的小demo，下边是完整代码：

```swift
struct ExampleView: View {
    @State private var width: CGFloat = 150
    @State private var fixedSize: Bool = true
    
    var body: some View {
        GeometryReader { proxy in
            
            VStack {
                Spacer()
                
                VStack {
                    LittleSquares(total: 7)
                        .border(Color.green)
                        .fixedSize(horizontal: self.fixedSize, vertical: false)
                }
                .frame(width: self.width)
                .border(Color.primary)
                .background(MyGradient())
                
                Spacer()
                
                Form {
                    Slider(value: self.$width, in: 0...proxy.size.width)
                    Toggle(isOn: self.$fixedSize) { Text("Fixed Width") }
                }
            }
        }.padding(.top, 140)
    }
}

struct LittleSquares: View {
    let sqSize: CGFloat = 20
    let total: Int
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 5) {
                ForEach(0..<self.maxSquares(proxy), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 5).frame(width: self.sqSize, height: self.sqSize)
                        .foregroundColor(self.allFit(proxy) ? .green : .red)
                }
            }
        }.frame(idealWidth: (5 + self.sqSize) * CGFloat(self.total), maxWidth: (5 + self.sqSize) * CGFloat(self.total))
    }

    func maxSquares(_ proxy: GeometryProxy) -> Int {
        return min(Int(proxy.size.width / (sqSize + 5)), total)
    }
    
    func allFit(_ proxy: GeometryProxy) -> Bool {
        return maxSquares(proxy) == total
    }
}

struct MyGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.1), Color.green.opacity(0.1)]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 1, y: 1))
    }
}
```

运行效果如下：

![10](https://i.loli.net/2020/06/13/5HUgeZXkbCf69Nj.gif)

上边的代码其实很简单，如果idealWidth来固定住view的宽度，那么view的宽度就不会改变，这在某些场景下还是挺有用的。

上边例子中最核心的代码是：

```sw
.frame(idealWidth: (5 + self.sqSize) * CGFloat(self.total), maxWidth: (5 + self.sqSize) * CGFloat(self.total))
```



## Layout Priority

SwiftUI中，view默认的layout priority 都是0，对于同一层级的view来说，系统会按照顺序进行布局，当我们使用` .layourPriority()`修改了布局的优先级后，系统则优先布局高优先级的view。

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("床前明月光，疑是地上霜")
                .background(Color.green)
            Text("举头望明月，低头思故乡")
                .background(Color.blue)
        }
        .frame(width: 100, height: 100)
    }
}
```

![11](https://i.loli.net/2020/06/13/qO3WEIS5pf8Pxyw.png)

可以看出来，这2个text的优先级是相同的，因此他们平分布局空间，我们给第2个text提升一点优先级：

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("床前明月光，疑是地上霜")
                .background(Color.green)
            Text("举头望明月，低头思故乡")
                .background(Color.blue)
                .layoutPriority(1)
        }
        .frame(width: 100, height: 100)
    }
}

```

![12](https://i.loli.net/2020/06/13/PHJyCXjzL16nRVS.png)

可以明显的看出来，优先布局第2个text。符合我们的预期。

## 总结

这篇文章中，讲解了frame的用法，fixedSize和layoutPriority的用法，要想理解这些用法，必须理解布局的3大原则：

- 父view提供一个建议的size
- view根据自身的特点再结合它的child计算出一个size
- 使用该size在父view中布局

*注：上边的内容参考了网站https://swiftui-lab.com/frame-behaviors/，如有侵权，立即删除。
