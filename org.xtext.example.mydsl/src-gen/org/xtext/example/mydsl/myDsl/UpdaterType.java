/**
 * generated by Xtext 2.11.0-SNAPSHOT
 */
package org.xtext.example.mydsl.myDsl;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.Enumerator;

/**
 * <!-- begin-user-doc -->
 * A representation of the literals of the enumeration '<em><b>Updater Type</b></em>',
 * and utility methods for working with them.
 * <!-- end-user-doc -->
 * @see org.xtext.example.mydsl.myDsl.MyDslPackage#getUpdaterType()
 * @model
 * @generated
 */
public enum UpdaterType implements Enumerator
{
  /**
   * The '<em><b>SGD</b></em>' literal object.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #SGD_VALUE
   * @generated
   * @ordered
   */
  SGD(0, "SGD", "sgd"),

  /**
   * The '<em><b>ADAM</b></em>' literal object.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #ADAM_VALUE
   * @generated
   * @ordered
   */
  ADAM(1, "ADAM", "adam"),

  /**
   * The '<em><b>ADADELTA</b></em>' literal object.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #ADADELTA_VALUE
   * @generated
   * @ordered
   */
  ADADELTA(2, "ADADELTA", "adadelta"),

  /**
   * The '<em><b>NESTEROVS</b></em>' literal object.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #NESTEROVS_VALUE
   * @generated
   * @ordered
   */
  NESTEROVS(3, "NESTEROVS", "nestrovs"),

  /**
   * The '<em><b>ADAGRAD</b></em>' literal object.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #ADAGRAD_VALUE
   * @generated
   * @ordered
   */
  ADAGRAD(4, "ADAGRAD", "adagrad"),

  /**
   * The '<em><b>RMSPROP</b></em>' literal object.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #RMSPROP_VALUE
   * @generated
   * @ordered
   */
  RMSPROP(5, "RMSPROP", "rmsprop");

  /**
   * The '<em><b>SGD</b></em>' literal value.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of '<em><b>SGD</b></em>' literal object isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @see #SGD
   * @model literal="sgd"
   * @generated
   * @ordered
   */
  public static final int SGD_VALUE = 0;

  /**
   * The '<em><b>ADAM</b></em>' literal value.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of '<em><b>ADAM</b></em>' literal object isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @see #ADAM
   * @model literal="adam"
   * @generated
   * @ordered
   */
  public static final int ADAM_VALUE = 1;

  /**
   * The '<em><b>ADADELTA</b></em>' literal value.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of '<em><b>ADADELTA</b></em>' literal object isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @see #ADADELTA
   * @model literal="adadelta"
   * @generated
   * @ordered
   */
  public static final int ADADELTA_VALUE = 2;

  /**
   * The '<em><b>NESTEROVS</b></em>' literal value.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of '<em><b>NESTEROVS</b></em>' literal object isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @see #NESTEROVS
   * @model literal="nestrovs"
   * @generated
   * @ordered
   */
  public static final int NESTEROVS_VALUE = 3;

  /**
   * The '<em><b>ADAGRAD</b></em>' literal value.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of '<em><b>ADAGRAD</b></em>' literal object isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @see #ADAGRAD
   * @model literal="adagrad"
   * @generated
   * @ordered
   */
  public static final int ADAGRAD_VALUE = 4;

  /**
   * The '<em><b>RMSPROP</b></em>' literal value.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of '<em><b>RMSPROP</b></em>' literal object isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @see #RMSPROP
   * @model literal="rmsprop"
   * @generated
   * @ordered
   */
  public static final int RMSPROP_VALUE = 5;

  /**
   * An array of all the '<em><b>Updater Type</b></em>' enumerators.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  private static final UpdaterType[] VALUES_ARRAY =
    new UpdaterType[]
    {
      SGD,
      ADAM,
      ADADELTA,
      NESTEROVS,
      ADAGRAD,
      RMSPROP,
    };

  /**
   * A public read-only list of all the '<em><b>Updater Type</b></em>' enumerators.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public static final List<UpdaterType> VALUES = Collections.unmodifiableList(Arrays.asList(VALUES_ARRAY));

  /**
   * Returns the '<em><b>Updater Type</b></em>' literal with the specified literal value.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param literal the literal.
   * @return the matching enumerator or <code>null</code>.
   * @generated
   */
  public static UpdaterType get(String literal)
  {
    for (int i = 0; i < VALUES_ARRAY.length; ++i)
    {
      UpdaterType result = VALUES_ARRAY[i];
      if (result.toString().equals(literal))
      {
        return result;
      }
    }
    return null;
  }

  /**
   * Returns the '<em><b>Updater Type</b></em>' literal with the specified name.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param name the name.
   * @return the matching enumerator or <code>null</code>.
   * @generated
   */
  public static UpdaterType getByName(String name)
  {
    for (int i = 0; i < VALUES_ARRAY.length; ++i)
    {
      UpdaterType result = VALUES_ARRAY[i];
      if (result.getName().equals(name))
      {
        return result;
      }
    }
    return null;
  }

  /**
   * Returns the '<em><b>Updater Type</b></em>' literal with the specified integer value.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the integer value.
   * @return the matching enumerator or <code>null</code>.
   * @generated
   */
  public static UpdaterType get(int value)
  {
    switch (value)
    {
      case SGD_VALUE: return SGD;
      case ADAM_VALUE: return ADAM;
      case ADADELTA_VALUE: return ADADELTA;
      case NESTEROVS_VALUE: return NESTEROVS;
      case ADAGRAD_VALUE: return ADAGRAD;
      case RMSPROP_VALUE: return RMSPROP;
    }
    return null;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  private final int value;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  private final String name;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  private final String literal;

  /**
   * Only this class can construct instances.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  private UpdaterType(int value, String name, String literal)
  {
    this.value = value;
    this.name = name;
    this.literal = literal;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public int getValue()
  {
    return value;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public String getName()
  {
    return name;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public String getLiteral()
  {
    return literal;
  }

  /**
   * Returns the literal value of the enumerator, which is its string representation.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String toString()
  {
    return literal;
  }
  
} //UpdaterType
