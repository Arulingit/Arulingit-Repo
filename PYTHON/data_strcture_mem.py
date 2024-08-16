import numpy as np
array1=np.array(['APPLEWELCOME','GOUA','ORANGE','GRAPES'])
#array2=np.array([[[0,1],[0,2]],[[1,1],[1,2]],[[2,2],[2,0]]])
#array3=np.array([[[0,1],[0,2]],[[1,1],[1,2]]])
print("1d-\n",array1)
#print("2d-\n",array2)
#print("2d-\n",array3)
print("encode-\n",array1.dtype)
byte_lists=np.char.encode(array1, encoding='utf-8')
print ("encode_chages-\n",byte_lists.dtype)     


emoji = '😊'
print("Emoji:", emoji)
print("Unicode Code Point:", ord(emoji))

   