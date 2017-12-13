library(keras)
library(dplyr)

cifar10_data = dataset_cifar10() #結構時間かかります

#訓練データとテストデータ読み込み
cifar10_data_train = cifar10_data$train
cifar10_data_test = cifar10_data$test

#データから特徴量とラベルを取得
  cifar10_data_train_x = cifar10_data_train$x
cifar10_data_train_y = cifar10_data_train$y
cifar10_data_test_x = cifar10_data_test$x
cifar10_data_test_y = cifar10_data_test$y

#訓練データとテストデータから、ラベル1と2のみ抽出
cifar10_data_train_x_0or1 = cifar10_data_train_x[cifar10_data_train_y %in% c(0,1), , ,]
cifar10_data_train_y_0or1 = cifar10_data_train_y[cifar10_data_train_y %in% c(0,1)] %>% as.matrix()

cifar10_data_test_x_0or1 = cifar10_data_test_x[cifar10_data_test_y %in% c(0,1), , ,]
cifar10_data_test_y_0or1 = cifar10_data_test_y[cifar10_data_test_y %in% c(0,1)] %>% as.matrix()

## 0~1の変数に
X_train = cifar10_data_train_x_0or1 / 255
X_test = cifar10_data_test_x_0or1 / 255

## one-hotに
Y_train = to_categorical(cifar10_data_train_y_0or1, num_classes = 2)
Y_test = to_categorical(cifar10_data_test_y_0or1, num_classes = 2)

###########
## keras ##
###########
model = keras_model_sequential()

model %>%
  
  ## 畳み込み層
  layer_conv_2d(
    filter = 32, kernel_size = c(3,3), padding = "same", 
    input_shape = c(32, 32, 3)
  ) %>%
  layer_activation("relu") %>%
  
  ## 畳み込み層
  layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
  layer_activation("relu") %>%
  
  ## プーリング層 →
  layer_max_pooling_2d(pool_size = c(2,2)) %>%

  ## 畳み込み層
  layer_conv_2d(filter = 64, kernel_size = c(3,3), padding = "same") %>%
  layer_activation("relu") %>%
  
  ## 畳み込み層
  layer_conv_2d(filter = 64, kernel_size = c(3,3)) %>%
  layer_activation("relu") %>%
  
  ## プーリング層
  layer_max_pooling_2d(pool_size = c(2,2)) %>%

　## 全結合　
  layer_flatten() %>%
  layer_dense(512) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  
  layer_dense(2) %>%
  layer_activation("softmax")

adam = optimizer_adam(lr = 1e-4)

model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = adam,
  metrics = "accuracy"
)

model %>% fit(
  X_train, Y_train,
  batch_size = 32,
  epochs = 2,
  validation_data = list(X_test, Y_test),
  shuffle = TRUE
)
