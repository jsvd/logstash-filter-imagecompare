# translated algorithm from http://mindmeat.blogspot.fr/2008/07/java-image-comparison.html
require 'java'
require 'stringio'

import com.sun.image.codec.jpeg.JPEGCodec
import java.awt.image.BufferedImage
import java.awt.Color
import javax.swing.GrayFilter

class ImageComparator

  def initialize(img1_string, img2_string)
    @img1 = loadJPG(img1_string)
    @img2 = loadJPG(img2_string)
    @imgc = nil
    @comparex = 0
    @comparey = 0
    @factorA = 0
    @factorD = 10
    @match = false
    @debugMode = 0 # 1: textual indication of change, 2: difference of factors

    autoSetParameters()
  end

  def self.similar_images?(img1_path, img2_path)
    ic = ImageComparator.new(img1_path, img2_path)
    ic.setParameters(8, 6, 10, 10)
    ic.setDebugMode(2)
    ic.compare()
    ic.match()
  end

  def autoSetParameters
    @comparex = 10
    @comparey = 10
    @factorA = 10
    @factorD = 10
  end

  def setParameters(x, y, factorA, factorD)
    @comparex = x
    @comparey = y
    @factorA = factorA
    @factorD = factorD
  end

  def setDebugMode(m)
    @debugMode = m
  end

  def compare()
    imgc = imageToBufferedImage(@img2)
    gc = imgc.createGraphics()
    gc.setColor(Color::RED)
    @img1 = imageToBufferedImage(GrayFilter.createDisabledImage(@img1))
    @img2 = imageToBufferedImage(GrayFilter.createDisabledImage(@img2))
    blocksx = (@img1.getWidth().to_f / @comparex)
    blocksy = (@img1.getHeight().to_f / @comparey)
    @match = true
    @comparey.times do |y|
      @comparex.times do |x|
        b1 = getAverageBrightness(@img1.getSubimage(x*blocksx, y*blocksy, blocksx - 1, blocksy - 1))
        b2 = getAverageBrightness(@img2.getSubimage(x*blocksx, y*blocksy, blocksx - 1, blocksy - 1))
        diff = (b1 - b2).abs
        if (diff > @factorA)
          gc.drawRect(x*blocksx, y*blocksy, blocksx - 1, blocksy - 1);
          @match = false
        end
      end
    end
  end

  def getChangeIndicator
    @imgc
  end

  def getAverageBrightness(img)
    r = img.getData()
    total = 0
    r.getHeight.times do |y|
      r.getWidth.times do |x|
        total += r.getSample(r.getMinX() + x, r.getMinY() + y, 0)
      end
    end
    return (total / ((r.getWidth()/@factorD)*(r.getHeight()/@factorD))).to_i
  end


  def match
    @match
  end

  def imageToBufferedImage(img)
    bi = BufferedImage.new(img.getWidth(nil), img.getHeight(nil), BufferedImage::TYPE_INT_RGB)
    g2 = bi.createGraphics()
    g2.drawImage(img, nil, nil)
    bi
  end

  def saveJPG(img, filename)
    bi = imageToBufferedImage(img)
    out = nil
    out = FileOutputStream.new(filename)
    encoder = JPEGCodec.createJPEGEncoder(out)
    param = encoder.getDefaultJPEGEncodeParam(bi)
    param.setQuality(0.8,false)
    encoder.setJPEGEncodeParam(param)
    encoder.encode(bi);
    out.close()
  end

  def loadJPG(string)
    img_in = nil;
    img_in = StringIO.new(string).to_inputstream
    decoder = JPEGCodec.createJPEGDecoder(img_in)
    bi = nil
    bi = decoder.decodeAsBufferedImage()
    img_in.close()
    bi
  end
end
