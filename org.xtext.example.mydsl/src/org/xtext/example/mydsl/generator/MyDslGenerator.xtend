/*
 * generated by Xtext unknown
 */
package org.xtext.example.mydsl.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.xtext.example.mydsl.myDsl.LayerTuple
import org.xtext.example.mydsl.myDsl.Network
import org.xtext.example.mydsl.myDsl.Layer
import org.xtext.example.mydsl.myDsl.LayerDeclaration
import org.eclipse.emf.common.util.EList
import org.xtext.example.mydsl.myDsl.LayerBody
import org.xtext.example.mydsl.myDsl.ConvLayerBody
import org.xtext.example.mydsl.myDsl.BranchBody
import org.xtext.example.mydsl.myDsl.impl.InParamImpl

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MyDslGenerator extends AbstractGenerator {

    var String weightInit
    var String biasInit
    var LayerTuple prevLayer = null
    var LayerTuple curLayer = null
    var LayerTuple tempLayer = null

    val String defaultWeightsInit = 'xavier'
    val String defaultBiasInit = 'constant'
    val String defaultOutputLabels = 'labels'
    var String fileName = 'network'

    // https://software.intel.com/en-us/articles/training-and-deploying-deep-learning-networks-with-caffe-optimized-for-intel-architecture
    // http://adilmoujahid.com/posts/2016/06/introduction-deep-learning-python-caffe/

    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
        generateProtoTxtFile(resource, fsa)
        generateSolverFile(resource, fsa)
        generateExecutionScript(resource, fsa)
        generateCreateDbScript(resource, fsa)
        generatePostImageScript(resource, fsa)
        generatePrintGraphScript(resource, fsa)
        generateTrainScript(resource, fsa)
    }

    def generatePostImageScript(Resource resource, IFileSystemAccess2 fsa) {
        fsa.generateFile(fileName + "-post-db-image.sh", '''
		«FOR net : resource.allContents.filter(Network).toIterable»
		«net.caffePath»/build/tools/compute_image_mean -backend=lmdb «net.outputPath»/train_db «net.outputPath»/«fileName»-mean.binaryproto
		«ENDFOR»
		''')
    }

    def generatePrintGraphScript(Resource resource, IFileSystemAccess2 fsa) {
        fsa.generateFile(fileName + "-print-graph.sh", '''
		«FOR net : resource.allContents.filter(Network).toIterable»
		python «net.caffePath»/python/«fileName»-draw_net.py «net.outputPath»/«fileName»-network.prototxt «net.outputPath»/«fileName»-caffe_model.png
		«ENDFOR»
		''')
    }

    def generateTrainScript(Resource resource, IFileSystemAccess2 fsa) {
        fsa.generateFile(fileName + "-train.sh", '''
		«FOR net : resource.allContents.filter(Network).toIterable»
		caffe train --solver «net.outputPath»/«fileName»-solver.prototxt 2>&1 | tee «net.outputPath»/«fileName»-model_train.log
		«ENDFOR»
		''')
    }

    def generateCreateDbScript(Resource resource, IFileSystemAccess2 fsa) {
        fsa.generateFile(fileName + "-create-db.py", '''
		«FOR net : resource.allContents.filter(Network).toIterable»
		import os
		import glob
		import random
		import itertools
		import numpy as np
		import cv2
		import lmdb
		try:
		    import caffe
		    from caffe.proto import caffe_pb2
		except:
		    raise ImportError('Must be able to import Caffe modules to use this module')

		#Size of images
		IMAGE_WIDTH = «net.imgSize»
		IMAGE_HEIGHT = «net.imgSize»
		CHANNELS = «net.imgChannels»

		ROOT_PATH = '«net.outputPath»/'
		TRAIN_PATH = '«net.trainPath»/'
		VALIDATION_PATH = '«net.valPath»/'

		#Create index map for labels
		labels_index = -1
		labels_map = {}

		#Craete data lists
		train_data_file = {}
		validation_data_file = {}

		def transform_img(img, img_width=IMAGE_WIDTH, img_height=IMAGE_HEIGHT):
		    #Histogram Equalization
		    img[:, :, 0] = cv2.equalizeHist(img[:, :, 0])
		    img[:, :, 1] = cv2.equalizeHist(img[:, :, 1])
		    img[:, :, 2] = cv2.equalizeHist(img[:, :, 2])
		    #Image Resizing
		    img = cv2.resize(img, (img_width, img_height), interpolation = cv2.INTER_CUBIC)
		    return img

		def make_datum(img, label):
		    #image is numpy.ndarray format. BGR instead of RGB
		    return caffe_pb2.Datum(
		        channels=CHANNELS,
		        width=IMAGE_WIDTH,
		        height=IMAGE_HEIGHT,
		        label=label,
		        data=np.rollaxis(img, 2).tostring())

		def add_files(dir, data_list):
		    for root, subdirs, files in os.walk(dir):
		        for file in files:
		            if file.endswith(".png"):
		                data_list.append(root + '/' + file)

		def index_label(img_path):
		    global labels_index
		    tmp = os.path.dirname(img_path)
		    path_names = tmp.split('/')
		    #take last entry (directory name) as key
		    label = path_names[-1]
		    index = -1
		    if labels_map.has_key(label):
		        index = labels_map[label]
		    else:
		        labels_index += 1
		        labels_map[label] = labels_index
		        index = labels_index
		    return index

		def craete_lmdb(lmbd_file, data, data_mapping):
		    in_db = lmdb.open(lmbd_file, map_size=int(1e12))
		    with in_db.begin(write=True) as in_txn:
		        for in_idx, img_path in enumerate(data):
		            if in_idx %  6 == 0:
		                continue
		            img = cv2.imread(img_path, cv2.IMREAD_COLOR)
		            img = transform_img(img, img_width=IMAGE_WIDTH, img_height=IMAGE_HEIGHT)
		            index = index_label(img_path)
		            data_mapping[img_path] = index
		            datum = make_datum(img, index)
		            in_txn.put('{:0>5d}'.format(in_idx), datum.SerializeToString())
		    in_db.close()

		def write_map(map, filename):
		    if os.path.exists(filename):
		        os.remove(filename)
		    with open(filename, "a") as input_file:
		        for k, v in map.items():
		            line = '{} {}\n'.format(k, v)
		            input_file.write(line)

		def write_list(values, filename):
		    if os.path.exists(filename):
		        os.remove(filename)
		    with open(filename, "a") as input_file:
		        for v in values:
		            line = '{}\n'.format(v)
		            input_file.write(line)

		train_lmdb = ROOT_PATH + 'train_db'
		validation_lmdb = ROOT_PATH + 'val_db'

		os.system('rm -rf  ' + train_lmdb)
		os.system('rm -rf  ' + validation_lmdb)

		train_data = []
		validation_data = []

		print 'Scan train data directory'
		add_files(TRAIN_PATH, train_data)
		print 'Scan validation data directory'
		add_files(VALIDATION_PATH, validation_data)

		print 'Shuffle train_data'
		random.shuffle(train_data)
		print 'Creating train_lmdb'
		craete_lmdb(train_lmdb, train_data, train_data_file)
		print 'Creating validation_lmdb'
		craete_lmdb(validation_lmdb, validation_data, validation_data_file)
		print 'Finished processing all images'

		print 'Write stats files'
		labels_list = list(labels_map.values())
		labels_list.sort()
		write_list(labels_list, ROOT_PATH + 'labels.txt')
		write_map(train_data_file, ROOT_PATH + 'train.txt')
		write_map(validation_data_file, ROOT_PATH + 'val.txt')
		«ENDFOR»
		''')
    }

    def generateSolverFile(Resource resource, IFileSystemAccess2 fsa) {
        fsa.generateFile(fileName + "-solver.prototxt", '''
		«FOR net : resource.allContents.filter(Network).toIterable»
		net: "«net.outputPath»/network.prototxt"
		test_iter: 1000
		test_interval: 1000
		base_lr: «net.learningRate»
		lr_policy: "step"
		gamma: 0.1
		stepsize: 2500
		display: 50
		max_iter: 40000
		momentum: 0.9
		weight_decay: 0.0005
		snapshot: 5000
		snapshot_prefix: "«net.outputPath»/caffe_model"
		solver_mode: GPU
		«ENDFOR»
		''')
    }

    def generateExecutionScript(Resource resource, IFileSystemAccess2 fsa) {
        fsa.generateFile(fileName + "-predict.py", '''
		import numpy as np
		import matplotlib.pyplot as plt
		import sys
		import caffe

		# Set the right path to your model definition file, pretrained model weights,
		# and the image you would like to classify.
		MODEL_FILE = '«fileName»-network.prototxt'
		PRETRAINED = 'network.caffemodel'

		# load the model
		caffe.set_mode_gpu()
		caffe.set_device(0)
		net = caffe.Classifier(MODEL_FILE, PRETRAINED,
		                       mean=np.load('data/train_mean.npy').mean(1).mean(1),
		                       channel_swap=(2,1,0),
		                       raw_scale=255,
		                       image_dims=(256, 256))
		print "successfully loaded classifier"

		# test on a image
		IMAGE_FILE = 'path/to/image/img.png'
		input_image = caffe.io.load_image(IMAGE_FILE)
		# predict takes any number of images,
		# and formats them for the Caffe net automatically
		pred = net.predict([input_image])
		''')
    }

    def void generateProtoTxtFile(Resource resource, IFileSystemAccess2 fsa) {
        val String result = '''
		«FOR net : resource.allContents.filter(Network).toIterable»
		name: "«fileName = net.name»"
		layer {
			name: "train-data"
			type: "Data"
			top: "data"
			top: "label"
			transform_param {
		    	mirror: true
		    	crop_size: «net.imgSize»
		    	#mean_file: «net.outputPath»/«fileName»-mean.binaryproto
			}
			data_param {
				«IF net.trainPath != null»
				#source: "«net.outputPath»/train_db"
			    «ENDIF»
			    batch_size: «net.batchSize»
			    #backend: LMDB
			}
			include { stage: "train" }
		}
		layer {
			name: "val-data"
			type: "Data"
			top: "data"
			top: "label"
			transform_param {
				mirror: false
				crop_size: «net.imgSize»
				#mean_file: «net.outputPath»/«fileName»-mean.binaryproto
			}
			data_param {
				«IF net.valPath != null»
				#source: "«net.outputPath»/val_db"
			    «ENDIF»
			    batch_size: «net.batchSize»
			    #backend: LMDB
			}
			include { stage: "val" }
		}
		«FOR layer : net.layers»
			«generateLayer(net, layer)»
		«ENDFOR»
		layer {
			name: "accuracy"
			type: "Accuracy"
			bottom: "final-layer"
			bottom: "label"
			top: "accuracy"
			include { stage: "val" }
		}
		layer {
			name: "loss"
			type: "SoftmaxWithLoss"
			bottom: "final-layer"
			bottom: "label"
			top: "loss"
			exclude { stage: "deploy" }
		}
		layer {
			name: "softmax"
			type: "Softmax"
			bottom: "final-layer"
			top: "softmax"
			include { stage: "deploy" }
		}
		«ENDFOR»
		'''
        fsa.generateFile(fileName + "-network.prototxt", result)

        weightInit = null
        biasInit = null
        prevLayer = null
        curLayer = null
    }

    def String generateBranchLayer(Network net, BranchBody branchBody, EList<Layer> branchLayers, LayerTuple layerTuple) {
        tempLayer = prevLayer
        val String tmp = layerTuple.layerName.name
        layerTuple.layerName.name = prevLayer.layerName.name
        val String result = '''
        «FOR layer : branchLayers»
        «generateLayer(net, layer)»
        «ENDFOR»
        layer {
            bottom: "«layerTuple.in.name»"
            bottom: "«curLayer.layerName.name»"
            top: "«tmp»"
            name: "«tmp»"
            type: "Eltwise"
            eltwise_param { operation: «branchBody.operation» }
        }
        '''
        layerTuple.layerName.name = tmp
        prevLayer = tempLayer
        curLayer = layerTuple
        return result
    }

    def String generateLayer(Network net, Layer layer) {
        return '''
		«IF layer.layerDecl instanceof LayerDeclaration»
			«generateMultiLayer(net, layer, (layer.layerDecl as LayerDeclaration).layerTuple)»
		«ELSE»
			«generateSimpleLayer(net, layer, (layer.layerDecl as LayerTuple))»
		«ENDIF»
		'''
    }

    def String generateMultiLayer(Network net, Layer layer, EList<LayerTuple> layerTuples) {
        return '''
		«FOR lt : layerTuples»
			«generateSimpleLayer(net, layer, lt)»
		«ENDFOR»
		'''
    }

    def String generateSimpleLayer(Network net, Layer layer, LayerTuple layerTuple) {
        prevLayer = curLayer
        curLayer = layerTuple

        var String layerResult
        if (layer.type == 'pool') {
            val String poolingLayer = '''
		layer {
            «IF prevLayer == null»

			bottom: "data"
			«ELSEIF curLayer.in == null»

        bottom: "«prevLayer.layerName.name»"

            «ELSE»

        bottom: "«curLayer.in.name»"
		    «ENDIF»
		    top: "«curLayer.layerName.name»"
		    name: "«curLayer.layerName.name»"
		    type: "Pooling"
		    pooling_param {
		        kernel_size: «layerTuple.out.value»
		        «IF layer.poolLayerBody != null»
		        «IF layer.poolLayerBody.stride <= 0»
		        stride: 1
		        «ELSE»
		        stride: «layer.poolLayerBody.stride»
		        «ENDIF»
		        pool: «layer.poolLayerBody.poolingType»
		        «ENDIF»
		    }
		}
		'''
            layerResult = poolingLayer
        } else if (layer.type == 'branch') {
            var String branchLayer
            branchLayer = generateBranchLayer(net, layer.branchBody, layer.branchLayers, layerTuple);
            layerResult = branchLayer
        } else if (layer.type == 'norm') {
            if (curLayer.out == null)
                curLayer.out = prevLayer.out

            val String normLayer = '''
        layer {
            «IF prevLayer == null»

			bottom: "data"
			«ELSEIF curLayer.in == null»
            bottom: "«prevLayer.layerName.name»"
            «ELSE»
            bottom: "«curLayer.in.name»"
            «ENDIF»
            top: "«curLayer.layerName.name»"
            name: "«curLayer.layerName.name»"
            type: "BatchNorm"
            batch_norm_param {
                «IF layer.batchNormBody.useGlobalStats == null || layer.batchNormBody.useGlobalStats == 'true'»
                use_global_stats: true
                «ELSE»
                use_global_stats: false
                «ENDIF»
            }
        }
        '''
            layerResult = normLayer
        } else if (layer.type == 'scale') {
            if (curLayer.out == null)
                curLayer.out = prevLayer.out

            val String scaleLayer = '''
        layer {
            «IF prevLayer == null»

		    bottom: "data"
            «ELSEIF curLayer.in == null»
            bottom: "«prevLayer.layerName.name»"
            «ELSE»
            bottom: "«curLayer.in.name»"
            «ENDIF»
            top: "«curLayer.layerName.name»"
            name: "«curLayer.layerName.name»"
            type: "Scale"
            scale_param {
                «IF layer.scaleNormBody.useBiasTerm == null || layer.scaleNormBody.useBiasTerm == 'true'»
                bias_term: true
                «ELSE»
                bias_term: false
                «ENDIF»
            }
        }
        '''
            layerResult = scaleLayer
        } else {
            var String activation
            if (layer.layerBody != null && layer.layerBody.activType != null)
                activation = layer.layerBody.activType.toString
            else
                activation = 'ReLU'

            val String neuralLayer = '''
		layer {
			name: "«curLayer.layerName.name»"
			«IF layer.type == 'conv'»
			type: "Convolution"
			«ELSEIF layer.type == 'pool'»
			«ELSE»
			type: "InnerProduct"
			«ENDIF»
			«IF prevLayer == null»
			bottom: "data"
			«ELSEIF curLayer.in == null»
			bottom: "«prevLayer.layerName.name»"
			«ELSE»
			bottom: "«curLayer.in.name»"
			«ENDIF»
			top: "«curLayer.layerName.name»"
			param {
				lr_mult: 1
			}
			param {
				lr_mult: 2
			}
			«IF layer.convLayerBody != null»
				«generateConvParam(layerTuple, layer.convLayerBody, layer.layerBody)»
			«ELSEIF layer.poolLayerBody != null»
			«ELSE»
				«generateInnerProductParam(net, layerTuple, layer.layerBody)»
			«ENDIF»
		}
		layer {
			name: "«activation»_«curLayer.layerName.name»"
			type: "«activation»"
			bottom: "«curLayer.layerName.name»"
			top: "«curLayer.layerName.name»"
		}
		«IF layer.layerBody != null && layer.layerBody.dropout > 0»

        layer {
            name: "drop_«curLayer.layerName.name»"
            type: "Dropout"
            bottom: "«curLayer.layerName.name»"
            top: "«curLayer.layerName.name»"
            dropout_param {
                dropout_ratio: «layer.layerBody.dropout»
            }
        }
        «ENDIF»
		'''
            layerResult = neuralLayer
        }
        return layerResult
    }

    def void validateInitParams(LayerBody layerBody) {
        if (layerBody == null) {
            weightInit = defaultWeightsInit
            biasInit = defaultBiasInit
        }
        if (layerBody != null && layerBody.weightInit == null) {
            weightInit = defaultWeightsInit
        }
        if (layerBody != null && layerBody.biasInit == null) {
            biasInit = defaultBiasInit
        }
    }

    def String generateConvParam(LayerTuple layerTuple, ConvLayerBody convBody, LayerBody layerBody) {
        validateInitParams(layerBody)

        return '''
			convolution_param {
				num_output: «layerTuple.out.value»
			    kernel_size: «convBody.kernelSize»
			    «IF convBody.stride <= 0»
			    stride: 1
			    «ELSE»
			    stride: «convBody.stride»
			    «ENDIF»
			    weight_filler {
			      type: "«weightInit»"
			    }
			    bias_filler {
			      type: "«biasInit»"
			      value: 0.2
			    }
			}
		'''
    }

    def String generateInnerProductParam(Network net, LayerTuple layerTuple, LayerBody layerBody) {
        validateInitParams(layerBody)

        return '''
			inner_product_param {
				«IF layerTuple.out.strValue == defaultOutputLabels»
				num_output: «net.outputLabels»
				«ELSE»
				num_output: «layerTuple.out.value»
			    «ENDIF»
			    weight_filler {
			      type: "«weightInit»"
			    }
			    bias_filler {
			      type: "«biasInit»"
			    }
			}
		'''
    }

}
