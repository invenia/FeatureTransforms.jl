# API

## Transforms

### Abstract Transform Types
```@docs
Transform
AbstractScaling
```

### Implemented Transforms
```@docs
HoD
Power
Periodic
StandardScaling
IdentityScaling
InverseHyperbolicSine
LinearCombination
LogTransform
OneHotEncoding
```

## Applying Transforms

```@docs
FeatureTransforms.apply
FeatureTransforms.apply!
FeatureTransforms.apply_append
```

## Transform Interface
```@docs
FeatureTransforms.is_transformable
FeatureTransforms.transform!
FeatureTransforms.transform
```

## Deprecated funtionality
```@docs
MeanStdScaling
```
